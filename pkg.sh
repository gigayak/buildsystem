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
  --dependency_history dnsmasq --dependency_history gcc
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
echo "$(basename "$0"): building package $pkgname" >&2
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
echo "$(basename "$0"): propagating following environment variables:" >&2
echo "$(basename "$0"): $env_string" >&2

# Lowercase the package's name if needed.
lcname="$(echo "$pkgname" | tr '[:upper:]' '[:lower:]')"
if [[ "$lcname" != "$pkgname" ]]
then
  echo "$(basename "$0"): lowercasing package name '$pkgname'" >&2
  pkgname="$lcname"
fi

# Choose name to output package to.
outputname="$(qualify_dep "$target_arch" "$target_os" "$pkgname")"


# Check that the package actually exists!
SPECS="$(DIR)/pkgspecs"
for path in "$version"
do
  if [[ ! -e "$path" ]]
  then
    echo "$(basename "$0"): required: '$path', please create" >&2
    exit 1
  fi
done


# Scan for circular dependencies.
echo "$(basename "$0"): looking for $outputname in dependency history" >&2
cycle_found=0
cycle_culprit=""
for hist_entry in "${F_dependency_history[@]}"
do
  qhist="$(qualify_dep "$target_arch" "$target_os" "$hist_entry")"
  if [[ "$qhist" == "$outputname" ]]
  then
    echo "$(basename "$0"): $hist_entry is $qhist and is part of this build" >&2
    cycle_culprit="$qhist"
    cycle_found=1
    break
  else
    echo "$(basename "$0"): $hist_entry is $qhist and has been built fully" >&2
  fi
done
if (( "$cycle_found" && ! "$F_break_dependency_cycles" ))
then
  echo "$(basename "$0"): found a dependency cycle due to '$cycle_culprit'" >&2
  exit 1
elif (( "$cycle_found" ))
then
  echo "$(basename "$0"): WARNING: removing cyclic dependencies" >&2
  echo "$(basename "$0"): WARNING: this may lead to undefined behavior" >&2
fi


# Bring in dependencies and initialize system.
source "$(DIR)/arch.sh"
source "$(DIR)/mkroot.sh"

mkroot dir
echo "Operating on $dir"

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
    echo "${FUNCNAME[0]}: script '$script_path' does not exist" >&2
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
  echo "${FUNCNAME[0]}: copying '$script' to '${dir}${YAK_WORKSPACE}/$script'" >&2
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
  cmd="$cmd && ./$script"
  cmd="$cmd"' || echo "$?"'
  cmd="$cmd > $(sq "$YAK_WORKSPACE/FAILED")"
  env --ignore-environment "${env_vars[@]}" \
    "$chroot_loc" "$dir" \
    /bin/bash -l -c "$cmd"
  if [[ -e "${dir}${YAK_WORKSPACE}/FAILED" ]]
  then
    retval="$(cat "${dir}${YAK_WORKSPACE}/FAILED")"
    echo "${FUNCNAME[0]}: script '$script' failed with code $retval" >&2
    dont_depopulate_dynamic_fs_pieces "$dir"
    unregister_temp_file "$dir"
    echo "${FUNCNAME[0]}: directory $(sq "$dir") saved for inspection" >&2
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
      echo "${FUNCNAME[0]}: removing $_path" >&2
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

    # Convert dependency history array to a fresh set of flags.
    local _hist_flags
    _hist_flags=(--dependency_history="$pkgname")
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

# build-only deps
for builddeps in "${F_builddeps_script[@]}"
do
  echo "$(basename "$0"): running builddeps script for $outputname" >&2
  run_in_root "${builddeps}" > "$workdir/builddeps.txt"
  echo "$(basename "$0"): found build dependencies for $outputname:" >&2
  while read -r dep
  do
    if [[ -z "$dep" ]]
    then
      continue
    fi
    echo "$(basename "$0"):  - $dep" >&2
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
  echo "$(basename "$0"): running dependency listing script for $outputname" >&2
  # Watch out: this is an overwrite of deplist, not an append.  We then
  # append deplist to deps.txt, so they wind up out of sync if multiple
  # dependency scripts execute.
  deplist="$(run_in_root "${deps}")"
  echo "$(basename "$0"): found runtime dependencies for $outputname:" >&2
  while read -r dep
  do
    echo "$dep" >> "$workdir/deps.txt"
    if [[ -z "$dep" ]]
    then
      continue
    fi
    echo "$(basename "$0"):  - $dep" >&2
  done < <(echo "$deplist")
done
# this makes sure that our repeated overwrites of deplist are undone.
if [[ -e "$workdir/deps.txt" ]]
then
  deplist="$(<"$workdir/deps.txt")"
fi

# remove cycles if requested (and found)
if (( "$F_break_dependency_cycles" && "$cycle_found" ))
then
  echo "$(basename "$0"): attempting to remove cyclic dependency" >&2
  echo "$(basename "$0"): in package $outputname build" >&2
  found=0
  for possible_culprit in "${F_dependency_history[@]}"
  do
    deplist="$(echo "$deplist" \
      | grep -vE "^${possible_culprit}\$" \
      || true)"
    {
      grep -vE "^${possible_culprit}\$" "$workdir/deps.txt" \
      || true
    } > "$workdir/deps.txt.new"
    # diff returns nonzero for different files; zero for same file
    if ! diff "$workdir/deps.txt.new" "$workdir/deps.txt" >/dev/null 2>&1
    then
      echo "$(basename "$0"): removed cyclic dependency $possible_culprit" >&2
      found=1
    else
      echo "$(basename "$0"): did not remove dependency $possible_culprit" >&2
    fi
    mv -f "$workdir/deps.txt.new" "$workdir/deps.txt"
  done
  echo "$(basename "$0"): new $outputname deplist after cycle removal:" >&2
  while read -r newdep
  do
    echo "$(basename "$0"):  - $newdep" >&2
  done < "$workdir/deps.txt"
  if (( ! "$found" ))
  then
    echo "$(basename "$0"): failed to remove dependency cycle" >&2
    exit 1
  fi
fi


echo "$(basename "$0"): installing all dependencies for $outputname" >&2
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
    echo "$(basename "$0"): found dependency cycle that was" \
      "broken downstream; exiting." >&2
    exit 0
  fi
  echo "$(basename "$0"): found disallowed dependency cycle; failing." >&2
  exit 1
fi


for make in "${F_make_script[@]}"
do
  echo "$(basename "$0"): running make script $make for $outputname" >&2
  run_in_root "${make}"
done


echo "$(basename "$0"): snapshotting $outputname pre-install state" >&2
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
  echo "$(basename "$0"): running install script $install for $outputname" >&2
  run_in_root "${install}"
done


# Multiple version scripts are NOT allowed: only one version may be output.
echo "$(basename "$0"): running version script for $outputname" >&2
pkgversion="$(run_in_root "${version}")"
if [[ -z "$pkgversion" ]]
then
  echo "$(basename "$0"): version script '$version' yielded no output" >&2
  exit 1
fi
echo "$(basename "$0"): version for $outputname is: $pkgversion" >&2



echo "$(basename "$0"): finding differences from $outputname install" >&2

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
echo "$(basename "$0"): packaging different file for $outputname to" \
  "'$pkgdir'" >&2
retval=0
"$(DIR)/copy_diff_files.sh" "$dir" "$pkgdir" < "$diff" \
  || retval=$?
if (( "$retval" ))
then
  unregister_temp_file "$snapshot"
  unregister_temp_file "$dir"
  unregister_temp_file "$diffdir"
  echo "$(basename "$0"): copy_diff_files failed for $outputname; see:" >&2
  echo "$(basename "$0"): post-build snapshot: $snapshot" >&2
  echo "$(basename "$0"): post-install snapshot: $dir" >&2
  echo "$(basename "$0"): diff: $diff" >&2
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
      echo "$(basename "$0"): copying explicitly declared symlink: $path" >&2
      if [[ ! -d "$(dirname "$pkgdir/$path")" ]]
      then
        mkdir -pv "$(dirname "$pkgdir/$path")"
      fi
      ln -sv "$(readlink "$dir/$path")" "$pkgdir/$path"
    elif [[ -d "$dir/$path" && ! -L "$dir/$path" ]]
    then
      echo "$(basename "$0"): copying explicitly declared directory: $path" >&2
      uid="$(stat -c '%U' "$dir/$path")"
      gid="$(stat -c '%G' "$dir/$path")"
      perms="$(stat -c '%a' "$dir/$path")"
      mkdir -pv "$pkgdir/$path"
      chown "$uid:$gid" "$pkgdir/$path"
      chmod "$perms" "$pkgdir/$path"
    elif [[ -f "$dir/$path" && ! -L "$dir/$path" ]]
    then
      echo "$(basename "$0"): copying explicitly declared file: $path" >&2
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
      echo "$(basename "$0"): $pkgdir/$path was explicitly declared, but" >&2
      echo "$(basename "$0"): is not a directory or does not exist at all." >&2
      echo "$(basename "$0"): Explicit declarations are a hack with" >&2 
      echo "$(basename "$0"): limited scope.  Please reconsider." >&2
      exit 1
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
  cp -fv "$tmprepo/$outputname.$n" "/var/www/html/tgzrepo/$outputname.$n"
done
echo "$(basename "$0"): successfully built $outputname" >&2
