#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/repo.sh"
add_usage_note <<EOF
This script is used internally to take some package specs and turn them into
usable binary packages.  It provides enough indirection to be able to change
the packaging format of this distribution on a bit of a whim - which is helpful,
as two such changes were planned from the original RPM target.
EOF

# Core flags that you should really care about.
add_flag --required pkg_name "Name of the package to build."
add_flag --default="" target_architecture "Architecture to build package for."
add_flag --default="" target_distribution "Distribution to build package for."
add_usage_note <<'EOF'
--target_architecture and --target_distribution control which OS the package
should be built for.  For instance, Ubuntu (--target_distribution=ubuntu)
supports multiple architectures (--target_architecture=[i686|x86_64|???]).
For the most part, packages will only build natively - that is, in a host
environment that matches their target environment.  As such, these two flags
default to the host arch/distro.  They're only used when compiling across
boundaries, such as compiling $ARCH-tools from any OS environment, and when
compiling $ARCH-yak from $ARCH-tools2.  Using these flags does not trigger
any cross-compilation magic - that's added in the package specifications.
Adding these flags without making sure to use a cross compiling toolchain
in the package specification will just result in mislabeled binaries (i.e.
a host OS of i686 with --target_architecture=x86_64 will produce i686
binaries that are labeled as x86_64...).  If in doubt, start a VM with the
desired architecture and compile natively!
EOF
add_flag --array builddeps_script \
  "Name of the script that installs all build dependencies."
add_flag --array make_script \
  "Name of the script that builds the package."
add_flag --array install_script \
  "Name of the script that installs the package."
add_flag --array deps_script \
  "Name of the script that lists dependencies the package requires."
add_flag --required version_script \
  "Name of the script that determines the version of the installed package."

# Annoying flags dealing with implementation details.
add_flag --array dependency_history \
  "List of dependencies that led to this build in chronological order."
add_usage_note <<EOF
--dependency_history is an internal flag to help manage dependency cycles.
The leftmost value of the flag is expected to be the first dependency in the
chain - normally, the package that caused the build to kick off.  For example,
if building dnsmasq caused gcc to be requested, and gcc requested libgcc, and
we're now building libgcc, we'd expect the following flags in this order:
  --dependency_history x86_64-ubuntu:dnsmasq \
  --dependency_history x86_64-ubuntu:gcc
Note that there is no entry for libgcc here: that's provided by --pkg_name.
EOF
add_flag --boolean break_dependency_cycles \
  "Set this flag if obeying dependencies is optional: ahem, Ubuntu?"
add_usage_note <<EOF
--break_dependency_cycles exists solely to support Ubuntu packages, which
are allowed to have circular dependencies declared as a common practice.  When
apt-get encounters circular dependencies, it chooses an arbitrary point in the
circle, cuts the chain, and unrolls it.  It attempts to install packages that
have no postinst scripts first, which pkg.sh does not attempt to mirror, but
this should at least somewhat unbreak the gcc <-> libgcc interdependencies when
building with Ubuntu as a host OS.
EOF
parse_flags "$@"

pkgname="$F_pkg_name"
log_rote "building package $pkgname"
if type pstree >/dev/null 2>&1
then
  log_rote "$pkgname build invoked by: $(pstree -Alsp "$$")"
fi
version="$F_version_script"

# Manually export a select set of environment variables.
# These are all hacks to accomplish something dirty.
host_os="$("$(DIR)/os_info.sh" --distribution)"
host_arch="$("$(DIR)/os_info.sh" --architecture)"

target_arch=""
target_os=""
if [[ ! -z "$F_target_architecture" ]]
then
  target_arch="$F_target_architecture"
else
  target_arch="$host_arch"
fi
if [[ ! -z "$F_target_distribution" ]]
then
  target_os="$F_target_distribution"
else
  target_os="$host_os"
fi

env_vars=()
env_vars+=("YAK_PKG_NAME=$pkgname")
env_vars+=("YAK_HOST_OS=$host_os")
env_vars+=("YAK_HOST_ARCH=$host_arch")
env_vars+=("YAK_TARGET_OS=$target_os")
env_vars+=("YAK_TARGET_ARCH=$target_arch")
# TODO: Fully remove YAK_BUILDTOOLS in favor of YAK_BUILDSYSTEM.
workspace_root="/.build_workspace"
# YAK_BUILDTOOLS is assumed to be a subdirectory of YAK_BUILDSYSTEM elsewhere - beware!
env_vars+=("YAK_BUILDTOOLS=$workspace_root/buildsystem/buildtools")
env_vars+=("YAK_BUILDSYSTEM=$workspace_root/buildsystem")
env_vars+=("YAK_WORKSPACE=$workspace_root/workspace")
env_string=""
for env_var in "${env_vars[@]}"
do
  env_string="$env_string $env_var"
  export "$env_var"
done
log_rote "propagating following environment variables:"
log_rote "$env_string"

# Lowercase the package's name if needed.
lcname="$(echo "$pkgname" | tr '[:upper:]' '[:lower:]')"
if [[ "$lcname" != "$pkgname" ]]
then
  log_rote "lowercasing package name '$pkgname'"
  pkgname="$lcname"
fi

# Choose name to output package to.
outputname="$(qualify_dep "$target_arch" "$target_os" "$pkgname")"
export outputname_debug_exit_handler_needed=1
outputname_debug_exit_handler()
{
  if (( "$outputname_debug_exit_handler_needed" ))
  then
    log_error "failed to build $outputname"
  fi
}
register_exit_handler_back outputname_debug_exit_handler


# Check that the package actually exists!
SPECS="$(DIR)/pkgspecs"
for path in "$version"
do
  if [[ ! -e "$path" ]]
  then
    log_fatal "required: '$path', please create"
  fi
done


# Scan for circular dependencies.
log_rote "looking for $outputname in dependency history"
cycle_found=0
cycle_culprit=""
log_rote "dependency history for $outputname:"
log_rote "- $outputname (current build)"
for hist_entry in "${F_dependency_history[@]}"
do
  tag=""
  cyclic=0
  if [[ "$hist_entry" == "$outputname" ]]
  then
    tag=" (cyclic)"
    cyclic=1
  fi
  log_rote "- ${hist_entry}${tag}"
  if (( ! "$cycle_found" && "$cyclic" ))
  then
    cycle_culprit="$hist_entry"
    cycle_found=1
  fi
done
if (( "$cycle_found" && ! "$F_break_dependency_cycles" ))
then
  log_fatal "found a dependency cycle due to '$cycle_culprit'"
elif (( "$cycle_found" ))
then
  log_warn "removing cyclic dependencies; this may lead to undefined behavior"
fi


# Bring in dependencies and initialize system.
source "$(DIR)/arch.sh"
source "$(DIR)/mkroot.sh"

mkroot dir
log_rote "operating on $dir"

run_in_root()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <script_to_run>" >&2
    return 1
  fi
  local script_path="$1"

  if [[ ! -e "$script_path" ]]
  then
    log_error "script '$script_path' does not exist"
    return 2
  fi

  local script="$(basename "$script_path")"

  # HACK SCALE: MINOR
  #
  # The following cat invocation is not a useless use of cat.  It helps deal
  # with the fact that $script_path may not be a regular file, as process
  # substitution yields files like /dev/fd/63, which are named pipes.  These
  # can't be cp'ed, but can be streamed using cat...
  #
  # Additionally, the chmod is dangerous, but a named pipe would not have
  # the executable bit set.
  log_rote "copying '$script' to '${dir}${YAK_WORKSPACE}/$script'"
  cat "$script_path" > "${dir}${YAK_WORKSPACE}/$script"
  chmod +x "${dir}${YAK_WORKSPACE}/$script"

  # TODO: chroot_loc is a hack to get around lack of `which` binary in the
  #       stage2 image. Perhaps its implementation should be centralized, at
  #       least?
  chroot_loc="$(type chroot | sed -nre 's@^\s*chroot is (.*)$@\1@gp')"
  # TODO: the following is a terrible hack to get around the fact that
  #       chroot "$dir" /bin/bash -c 'exit 1' seems to fail miserably
  cmd="cd $(sq "$YAK_WORKSPACE")"
  # The bash configuration in Ubuntu doesn't export the PATH by default.
  # That means the following line mitigates issues such as:
  #   cc: error trying to exec 'cc1': execvp: No such file or directory
  cmd="$cmd && export PATH"
  # This ensures that path overrides due to YAK_TEST_CONFIG files are
  # carried through to commands executed in the chroot, allowing arbitrary
  # binaries to be overridden with stubs or other test doubles for testing.
  cmd="$cmd && source ${YAK_BUILDSYSTEM}/config.sh"
  cmd="$cmd && ./$script"
  cmd="$cmd"' || echo "$?"'
  cmd="$cmd > $(sq "$YAK_WORKSPACE/FAILED")"
  env --ignore-environment "${env_vars[@]}" \
    "$chroot_loc" "$dir" \
    /bin/bash -l -c "$cmd"
  if [[ -e "${dir}${YAK_WORKSPACE}/FAILED" ]]
  then
    retval="$(cat "${dir}${YAK_WORKSPACE}/FAILED")"
    log_error "script '$script' failed with code $retval"
    dont_depopulate_dynamic_fs_pieces "$dir"
    unregister_temp_file "$dir"
    log_rote "directory $(sq "$dir") saved for inspection"
    return 1
  fi
  return 0
}

# Clean up directories which should not contain stuff
cleanup_root()
{
  local _root="$1"

  # We'll clean up a whole bunch of directories:
  # - $YAK_WORKSPACE is used as our build directory, and may contain transient data.
  # - $YAK_BUILDSYSTEM has static binaries that we installed out of band.
  # - /tmp/ should never have persistent data, by definition.
  local _dir
  for _dir in "${_root}${YAK_WORKSPACE}" "${_root}${YAK_BUILDSYSTEM}" "$_root/tmp"
  do
    # Rather than delete and recreate, why don't we just empty each directory?
    # This should prevent permissions issues.
    local _path
    while read -r _path
    do
      log_rote "removing $_path"
      rm -rf "$_path"
    done < <(find "$_dir" -mindepth 1 -maxdepth 1)
  done
}

install_deps()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <file_containing_dependencies>" >&2
    return 1
  fi

  local _depfile="$1"

  local _dep
  while read -r _dep
  do
    if [[ -z "$_dep" ]]
    then
      continue
    fi

    # Prevent cycle detection from going haywire:
    # Abort early if package being built has somehow been installed.
    # This helps with two packages that depend on each other, such as:
    #   Package a depends on package b.
    #   Package b depends on package a.
    #   Build 1 is of package b.
    #     To build package b, dependencies a and b are found
    #   Build 2 is of package a.  Triggered by build 1.
    #     Within package a, dependencies a and b are found
    #   Build 3 is of package a.  Triggered by build 2.
    #     Within package a, dependencies a and b are found.
    #     a is removed as a cyclic dependency
    #     Dependency b remains.
    #   Build 4 is of package b.  Triggered by build 3.
    #     Within package b, dependencies a and b are found.
    #     a and b are removed as cyclic dependencies.
    #     No dependencies remain.
    #     Package b is output with no dependencies declared.
    #   Build 3 resumes.
    #     ???
    
    # Convert dependency history array to a fresh set of flags.
    local _hist_flags
    _hist_flags=(--dependency_history="$outputname")
    local _hist_entry
    for _hist_entry in "${F_dependency_history[@]}"
    do
      _hist_flags+=(--dependency_history="$_hist_entry")
    done

    local _dep_arch="$(dep2arch "$target_arch" "$target_os" "$_dep")"
    local _dep_os="$(dep2distro "$target_arch" "$target_os" "$_dep")"
    local _dep_name="$(dep2name "$target_arch" "$target_os" "$_dep")"

    "$(DIR)/install_pkg.sh" \
      --target_arch="$_dep_arch" \
      --target_distribution="$_dep_os" \
      --pkg_name="$_dep_name" \
      --install_root="$dir" \
      "${_hist_flags[@]}"
  done < "$_depfile"
}

# Create a directory to store scratch files in.
make_temp_dir workdir

# Populate directory with tools used in build scripts.
# TODO: Find a better way to install tools - perhaps allowing builddeps
#     script to rely on dependencies it declares by installing each builddep
#     the moment it is declared?
mkdir -pv "$dir"{"$YAK_WORKSPACE","$YAK_BUILDSYSTEM","$YAK_BUILDTOOLS"}
"$(DIR)/install_buildsystem.sh" --output_path="${dir}${YAK_BUILDSYSTEM}"
"$(DIR)/dump_config.sh" > "${dir}${YAK_BUILDSYSTEM}/inherited_config.sh"

# build-only deps
for builddeps in "${F_builddeps_script[@]}"
do
  log_rote "running builddeps script for $outputname"
  log_rote "builddeps script is named $(sq "$builddeps")"
  run_in_root "${builddeps}" > "$workdir/builddeps.txt"
  log_rote "found build dependencies for $outputname:"
  while read -r dep
  do
    if [[ -z "$dep" ]]
    then
      continue
    fi
    log_rote " - $dep"
  done < "$workdir/builddeps.txt"

  # Watch out: dependencies are intentionally installed as soon as possible.
  # One reason why can be seen in pkg.from_pip.sh: multiple builddeps
  # scripts are needed, as each script relies on packages from the prior
  # script.  The first script installs python, the second installs pip
  # USING python, and then the third and fourth build upon that.  Yeah, it's
  # ugly like that - but it's an okay stopgap while build scripts are all
  # separate pieces being called by the build framework.  When control is
  # inverted (build script says "ensure this dependency is installed" and it
  # gets installed), these issues will all go away...
  #
  # Note that inversion of control will be difficult due to cyclic
  # dependencies when converting packages from apt-get.  Fun.
  install_deps "$workdir/builddeps.txt"
  rm -fv "$workdir/builddeps.txt"
done

# non-build deps
deplist=""
for deps in "${F_deps_script[@]}"
do
  log_rote "running dependency listing script for $outputname"
  log_rote "dependency listing script is named $(sq "$deps")"
  # Watch out: this is an overwrite of deplist, not an append.  We then
  # append deplist to deps.txt, so they wind up out of sync if multiple
  # dependency scripts execute.
  deplist="$(run_in_root "${deps}")"
  log_rote "found runtime dependencies for $outputname:"
  while read -r dep
  do
    echo "$dep" >> "$workdir/deps.txt"
    if [[ -z "$dep" ]]
    then
      continue
    fi
    log_rote " - $dep"
  done < <(echo "$deplist")
done
# this makes sure that our repeated overwrites of deplist are undone.
if [[ -e "$workdir/deps.txt" ]]
then
  deplist="$(<"$workdir/deps.txt")"
fi

if (( "$F_break_dependency_cycles" ))
then
  log_rote "checking for cyclic deps in package $outputname"
  found=0
  for possible_culprit in "$outputname" "${F_dependency_history[@]}"
  do
    echo >/dev/null # vi's syntax highlighter does not want do to begin with {
    {
      while read -r possible_dep
      do
        q_pos_dep="$(qualify_dep "$target_arch" "$target_os" "$possible_dep")"
        if [[ "$q_pos_dep" == "$possible_culprit" ]]
        then
          continue
        fi
        echo "$possible_dep"
      done < "$workdir/deps.txt"
    } > "$workdir/deps.txt.new"
    # diff returns nonzero for different files; zero for same file
    if ! diff "$workdir/deps.txt.new" "$workdir/deps.txt" >/dev/null 2>&1
    then
      log_rote "removed cyclic dependency $possible_culprit"
      found=1
    else
      log_rote "did not remove dependency $possible_culprit"
    fi
    mv -f "$workdir/deps.txt.new" "$workdir/deps.txt"
  done
  deplist="$(<"$workdir/deps.txt")"
  log_rote "new $outputname deplist after cycle removal:"
  while read -r newdep
  do
    log_rote " - $newdep"
  done < "$workdir/deps.txt"
  if (( ! "$found" && "$cycle_found" ))
  then
    log_fatal "found a dependency cycle earlier, but failed to remove it"
  fi
fi


log_rote "installing all dependencies for $outputname"
if [[ -e "$workdir/deps.txt" ]]
then
  install_deps "$workdir/deps.txt"
fi


# This code prevents us from rebuilding packages that are a part of a cycle.
# If they've already been built successfully, and were then installed in our
# root, then it means that the cycle was not broken in this build, but was
# broken in a build it triggered.  Thus, this build should abort peacefully.
#
# It also prevents packages with cycles from building on systems that aren't
# Ubuntu, because cycles are annoying.
if [[ -e "$dir/.installed_pkgs/$outputname" ]]
then
  if (( "$F_break_dependency_cycles" ))
  then
    log_rote "found dependency cycle that was broken downstream; exiting"
    export outputname_debug_exit_handler_needed=0
    exit 0
  fi
  log_fatal "found disallowed dependency cycle"
fi


for make in "${F_make_script[@]}"
do
  log_rote "running make script $make for $outputname"
  run_in_root "${make}"
done


log_rote "snapshotting $outputname pre-install state"
make_temp_dir snapshot

# Unmount procfs/devfs as they will cause lots of "evaporating file"
# log messages which will cause rsync to take longer.
depopulate_dynamic_fs_pieces "$dir"
# The following options are --archive without -D:
# -D = --devices --specials
#      --devices = preserve device files (superuser only)
#      --specials = preserve special files
# These are excluded because procfs / devfs are kernel callback
# filesystems and will cause pain.
rsync \
  --recursive \
  --links \
  --times \
  --group --owner --perms \
  "$dir/" "$snapshot/"
# Repopulate procfs/devfs so that the install script can use them.
populate_dynamic_fs_pieces "$dir"


for install in "${F_install_script[@]}"
do
  log_rote "running install script $install for $outputname"
  run_in_root "${install}"
done


# Multiple version scripts are NOT allowed: only one version may be output.
log_rote "running version script for $outputname"
pkgversion="$(run_in_root "${version}")"
if [[ -z "$pkgversion" ]]
then
  log_fatal "version script '$version' yielded no output"
fi
log_rote "version for $outputname is: $pkgversion"



log_rote "finding differences from $outputname install"

# Set the path to create diffs at.
# We want this to be transient, but have no temp directory so far...
make_temp_dir diffdir
diff="$diffdir/${pkgname}.diff"
# devfs/procfs would cause problems with rsync; unmount them.
depopulate_dynamic_fs_pieces "$dir"
# HACK SCALE: MAJOR
#
# Some files really need to exist for a Linux distribution, or even chroot,
# to work.  For example, /proc exists in all of our chroots.  Since we won't
# be able to see that these were "added" during installation (as they already
# existed), we'll allow them to be explicitly packaged through an annoyingly
# hacky path: being listed in $YAK_WORKSPACE/extra_installed_paths.  We have to save
# off this file before it evaporates when we cleanup_root, though!
if [[ -e "${dir}${YAK_WORKSPACE}/extra_installed_paths" ]]
then
  cp {"${dir}${YAK_WORKSPACE}","$diffdir"}/extra_installed_paths
fi
cleanup_root "$dir"
# We'll use a dry run of rsync --archive without --times to
# evaluate what changed.  --times is removed to prevent us from
# having a package installation modify a file ONLY by touching it.
#
# --itemize-changes is used instead of --verbose to trigger
# output, as --verbose also includes a summary which complicates
# parsing.
#
# --archive == -rlptgoD
# -r = --recursive
# -l = --links = copy symlinks as symlinks
# -p = --perms = preserve permissions
# -t = --times = preserve mtimes
# -g = --group = preserve group
# -o = --owner = preserve owner
# -D = --devices --specials
#      --devices = preserve device files (superuser only)
#      --specials = preserve special files
rsync \
  --dry-run \
  --recursive \
  --links \
  --perms --group --owner \
  --devices --specials \
  --itemize-changes \
  "$dir/" "$snapshot/" \
  > "$diff"

# Create package output...
make_temp_dir pkgdir
log_rote "packaging different files for $outputname to '$pkgdir'"
retval=0
"$(DIR)/copy_diff_files.sh" "$dir" "$pkgdir" < "$diff" \
  || retval=$?
if (( "$retval" ))
then
  unregister_temp_file "$snapshot"
  unregister_temp_file "$dir"
  unregister_temp_file "$diffdir"
  log_error "copy_diff_files failed for $outputname; see:"
  log_error "  post-build snapshot: $snapshot"
  log_error "  post-install snapshot: $dir"
  log_error "  diff: $diff"
  exit 1
fi

# HACK SCALE: MAJOR
#
# This takes our list of explicitly declared files and directories to install,
# and explicitly installs them.  This is useful for installing stuff like
# /proc or /bin/sh, which tend to exist in a functional chroot, and thus won't
# see differences in some cases.
if [[ -e "$diffdir/extra_installed_paths" ]]
then
  while read -r path
  do
    if [[ -z "$path" ]]
    then
      continue
    fi
    if [[ -L "$dir/$path" ]]
    then
      log_rote "copying explicitly declared symlink: $path"
      if [[ ! -d "$(dirname "$pkgdir/$path")" ]]
      then
        mkdir -pv "$(dirname "$pkgdir/$path")"
      fi
      ln -sv "$(readlink "$dir/$path")" "$pkgdir/$path"
    elif [[ -d "$dir/$path" && ! -L "$dir/$path" ]]
    then
      log_rote "copying explicitly declared directory: $path"
      uid="$(stat -c '%U' "$dir/$path")"
      gid="$(stat -c '%G' "$dir/$path")"
      perms="$(stat -c '%a' "$dir/$path")"
      mkdir -pv "$pkgdir/$path"
      chown "$uid:$gid" "$pkgdir/$path"
      chmod "$perms" "$pkgdir/$path"
    elif [[ -f "$dir/$path" && ! -L "$dir/$path" ]]
    then
      log_rote "copying explicitly declared file: $path"
      uid="$(stat -c '%U' "$dir/$path")"
      gid="$(stat -c '%G' "$dir/$path")"
      perms="$(stat -c '%a' "$dir/$path")"
      if [[ ! -d "$(dirname "$pkgdir/$path")" ]]
      then
        mkdir -pv "$(dirname "$pkgdir/$path")"
      fi
      cp -f "$dir/$path" "$pkgdir/$path"
      chown "$uid:$gid" "$pkgdir/$path"
      chmod "$perms" "$pkgdir/$path"
    else
      log_fatal "$pkgdir/$path was explicitly declared, but is not a" \
        "directory or does not exist at all.  Explicit declarations are a" \
        "hack with limited scope.  Please reconsider."
    fi
  done < "$diffdir/extra_installed_paths"
fi

cleanup_root "$pkgdir"

# Generate package
cd "$pkgdir"
make_temp_dir tmprepo
tar -czf "$tmprepo/$outputname.tar.gz" .
echo "$pkgversion" > "$tmprepo/$outputname.version"
echo "$deplist" | sort | uniq > "$tmprepo/$outputname.dependencies"
touch "$tmprepo/$outputname.done"
for n in tar.gz version dependencies done
do
  cp -fv "$tmprepo/$outputname.$n" "$_REPO_LOCAL_PATH/$outputname.$n"
done
export outputname_debug_exit_handler_needed=0
log_rote "successfully built $outputname"
