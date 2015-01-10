#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
add_flag --required pkg_name "Name of the package to build."
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
add_flag --array opts_script \
  "Name of the script that provides additional flags for fpm (--provides)."
add_flag --array env \
  "An environment variable to export, in form 'KEY=value' with uppercase key."
add_flag --array file \
  "Add a file to the chroot, in form '/chroot/dest=/host/src'"
parse_flags

pkgname="$F_pkg_name"
export PKG_NAME="$pkgname"
version="$F_version_script"

# Export all requested environment variables
env_string="" # Used to propagate into chroot
for var in "${F_env[@]}"
do
  name="$(echo "$var" | sed -nre 's@^([^=]+)=.*$@\1@p')"
  value="$(echo "$var" | sed -nre 's@^[^=]+=(.*)$@\1@p')"
  if [[ -z "$name" ]]
  then
    echo "$(basename "$0"): invalid key in --env option '$var'" >&2
    exit 1
  fi
  ucname="$(echo "$name" | tr '[:lower:]' '[:upper:]')"
  if [[ "$ucname" != "$name" ]]
  then
    echo "$(basename "$0"): --env must be given all-caps name" >&2
    echo "$(basename "$0"): ('$name' is not all-caps)" >&2
  fi
  export "$name"="$value"
  env_string="$env_string $name=$(sq "$value")"
done
echo "Propagating following environment variables:"
echo "$env_string"

# Lowercase the package's name if needed.
lcname="$(echo "$pkgname" | tr '[:upper:]' '[:lower:]')"
if [[ "$lcname" != "$pkgname" ]]
then
  echo "Lowercasing the package name"
  pkgname="$lcname"
fi


# Check that the package actually exists!
SPECS="$DIR/pkgspecs"
for path in "$version"
do
  if [[ ! -e "$path" ]]
  then
    echo "$(basename "$0"): required: '$path', please create" >&2
    exit 1
  fi
done


# Bring in dependencies and initialize system.
source "$DIR/arch.sh"
source "$DIR/mkroot.sh"

# TODO: This is... odd and unintuitive.  No.
# Allow us to build the RPM repository without necessarily having the RPM
# repository built (fixes the bootstrapping cycle problem).
if [[ "$pkgname" == "jpg-repo" ]]
then
  mkroot dir --no-repo
else
  mkroot dir
fi
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
  echo "${FUNCNAME[0]}: copying '$script' to '$dir/root/$script'" >&2
  cat "$script_path" > "$dir/root/$script"
  chmod +x "$dir/root/$script"

  # TODO: the following is a terrible hack to get around the fact that
  #       chroot "$dir" /bin/bash -c 'exit 1' seems to fail miserably
  chroot "$dir" /bin/bash -c "cd /root && ${env_string} ./$script || echo \"\$?\" > /root/FAILED"
  if [[ -e "$dir/root/FAILED" ]]
  then
    retval="$(cat "$dir/root/FAILED")"
    echo "${FUNCNAME[0]}: script '$script' failed with code $retval" >&2
    return 1
  fi
  return 0
}

# Clean up directories which should not contain stuff
cleanup_root()
{
  local _root="$1"

  # We'll clean up a whole bunch of directories:
  # - /root/ is used as our home directory, and may contain transient data.
  # - /tmp/ should never have persistent data, by definition.
  local _dir
  for _dir in "$_root/root" "$_root/tmp"
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

# Make sure that a package exists in the default repositories.  Build it if
# it does not.
ensure_pkg_exists()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <pkg_name>" >&2
    return 1
  fi

  local _pkg="$1"

  echo "Making sure package '$_pkg' exists."

  # Create a test root to use.
  if [[ -z "$ensure_pkg_exists_root" ]]
  then
    if [[ "$pkgname" == "jpg-repo" ]]
    then
      mkroot ensure_pkg_exists_root --no-repo
    else
      mkroot ensure_pkg_exists_root
    fi
  fi
  local _root="$ensure_pkg_exists_root"

  # Check if the package exists.
  local _exists=1
  if [[ "$_pkg" == "python-"* && "$_pkg" != "python-devel" ]]
  then
    chroot "$_root" /bin/bash -c "yum list --disablerepo='*' --enablerepo=jpg '$_pkg'" || _exists=0
  else
    chroot "$_root" /bin/bash -c "yum list '$_pkg'" || _exists=0
  fi
  if (( ! "$_exists" ))
  then
    echo "Building nonexistent package '$_pkg'"
    "$DIR/pkg.from_name.sh" --pkg_name="$_pkg"
  fi
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
  local _to_install=()
  while read -r _dep
  do
    if [[ -z "$_dep" ]]
    then
      continue
    fi
    ensure_pkg_exists "$_dep"
    _to_install+=("$_dep")
  done < "$_depfile"

  # Since things may have changed during the ensure_pkg_exists call,
  # we'll reset our repository caches.  This will ensure that any new
  # packages we built appear properly.
  run_in_root <(echo "yum clean all")

  run_in_root <(echo "yum -y --nogpgcheck install ${_to_install[@]}")
}

# Create a directory to store scratch files in.
make_temp_dir workdir

base="${SPECS}/${pkgname}" 

# Populate the directory with any and all files requested.
for spec in "${F_file[@]}"
do
  dest_path="$(echo "$spec" | sed -nre 's@^([^=]+)=.*$@\1@p')"
  src_path="$(echo "$spec" | sed -nre 's@^[^=]+=(.*)$@\1@p')"
  if [[ -z "$dest_path" || -z "$src_path" ]]
  then
    echo "$(basename "$0"): invalid --file spec '$spec'" >&2
    exit 1
  fi
  # TODO: if this hack exists for too long, should mkdir -p dirname
  cp -v "$src_path" "$dir/$dest_path"
done

# build-only deps
for builddeps in "${F_builddeps_script[@]}"
do
  if [[ -e "${builddeps}" ]]
  then
    echo "Running builddeps script"
    run_in_root "${builddeps}" >> "$workdir/builddeps.txt"
  fi
done

# non-build deps
deplist=""
depflags=()
for deps in "${F_deps_script[@]}"
do
  echo "Running dependency listing script"
  if [[ -e "$deps" ]]
  then
    deplist="$(run_in_root "${deps}")"
    echo "Found dependencies:"
    while read -r dep
    do
      echo "$dep" >> "$workdir/builddeps.txt"
      if [[ -z "$dep" ]]
      then
        continue
      fi
      echo " - $dep"
      depflags+=(--depends "$dep")
    done < <(echo "$deplist")
  fi
done


if [[ -e "$workdir/builddeps.txt" ]]
then
  install_deps "$workdir/builddeps.txt"
fi


for make in "${F_make_script[@]}"
do
  if [[ -e "${make}" ]]
  then
    echo "Running make script"
    run_in_root "${make}"
  fi
done


echo "Snapshotting"
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
  if [[ -e "$install" ]]
  then
    echo "Running install script"
    run_in_root "${install}"
  fi
done


# Multiple version scripts are NOT allowed: only one version may be output.
echo "Running version script"
pkgversion="$(run_in_root "${version}")"
if [[ -z "$pkgversion" ]]
then
  echo "$(basename "$0"): version script '$version' yielded no output" >&2
  exit 1
fi
echo "Version is: $pkgversion"



for opts in "${F_opts_script[@]}"
do
  echo "Running extra options script"
  if [[ -e "$opts" ]]
  then
    while read -r opt
    do
      depflags+=("$opt")
    done < <(run_in_root "${opts}")
  fi
done


echo "Finding differences"

# Set the path to create diffs at.
# We want this to be transient, but have no temp directory so far...
make_temp_dir diffdir
diff="$diffdir/${pkgname}.diff"
# devfs/procfs would cause problems with rsync; unmount them.
depopulate_dynamic_fs_pieces "$dir"
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
echo "Packaging to '$pkgdir'"
"$DIR/copy_diff_files.py" "$dir" "$pkgdir" < "$diff"

cleanup_root "$pkgdir"

# Generate RPM
cd "$DIR"
paths=()
while read -r path
do
  paths+=("$(basename "$path")")
done < <(find "$pkgdir" -mindepth 1 -maxdepth 1)
make_temp_dir tmprepo
arch="$(architecture)"
source=dir
if (( ! "${#paths[@]}" ))
then
  source=empty
fi
fpm \
  -t rpm \
  -s "$source" \
  -n "$pkgname" \
  -v "$pkgversion" \
  -C "$pkgdir/" \
  -p "$tmprepo/$pkgname-$pkgversion-1.$arch.rpm" \
  "${depflags[@]}" \
  "${paths[@]}"

# Update repository
#repo="$DIR/repo"
repo="/var/www/html/repo"
if [[ ! -d "$repo" ]]
then
  mkdir -p "$repo"
  createrepo "$repo"
fi
cp -fv "$tmprepo/"* "$repo/"
createrepo --update "$repo"
