# /bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

if [[ ! -z "$_MKROOT_SH_INCLUDED" ]]
then
  return 0
fi
_MKROOT_SH_INCLUDED=1
source "$(DIR)/cleanup.sh"
source "$(DIR)/arch.sh"

# Create a bare-minimum CentOS installation in a temp directory,
# and then store the name of that directory into the environment
# variable named by the first argument.
#
# That is:
#   $ create_bare_root dir
#   $ ls -1 "$dir" | wc -l
#   27 # or however many
#
# TODO: make flag parsing in functions work, and apply it here
create_bare_root()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <env_var_to_store_dir_in>" >&2
    return 1
  fi
  local env="$1"

  if (( "$UID" != 0 ))
  then
    echo "${FUNCNAME[0]}: must be run as root (for chroot)" >&2
    return 1
  fi

  # Create temporary root.
  local _original_dir="$PWD"
  make_temp_dir "$env"
  local _root="${!env}"
  echo "${FUNCNAME[0]}: made temp dir '$_root'" >&2

  # Populate bare minimum packages to run.
  # TODO: Need a way of determining whether we need i686-tools or just bare OS
  local _pkgs=()
  # CentOS host
  # TODO: Check how hard bootstrap on Fedora / Scientific / Redhat would be.
  if which yum >/dev/null 2>&1
  then
    _pkgs=(rpm-build centos-release yum)
  # Ubuntu host
  elif which apt-get >/dev/null 2>&1
  then
    _pkgs=(base-ubuntu)
  # Assuming anything else is a stage2 Gigayak host.
  # TODO: Do a secondary check and chuck a wobbly if not on Gigayak here.
  # TODO: Don't use bare dependency names... specify constraint flags
  else
    _pkgs=()
    # Bare minimum to look anything like Linux:
    _pkgs+=(filesystem-skeleton)
    # Required to run all build shell scripts:
    _pkgs+=(i686-tools2:bash{,-aliases,-profile})
    # Brought in by buildtools/tool_names.sh:
    _pkgs+=(i686-tools2:coreutils{,-aliases})
    _pkgs+=(i686-tools2:gawk)
    _pkgs+=(i686-tools2:grep)
    # Used for getopt by flag.sh:
    _pkgs+=(i686-tools2:util-linux)
    # Used by flag.sh:
    _pkgs+=(i686-tools2:sed)
  fi
  local _pkg
  for _pkg in "${_pkgs[@]}"
  do
    echo "${FUNCNAME[0]}: installing $_pkg" >&2
    "$(DIR)/install_pkg.sh" --install_root="$_root" --pkg_name="$_pkg"
  done

  cd "$_original_dir"
}

existing_dynamic_fs_roots=()

populate_dynamic_fs_pieces()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <chroot_to_populate>" >&2
    return 1
  fi
  local _root="$1"

  if [[ ! -d "$_root" ]]
  then
    echo "${FUNCNAME[0]}: target chroot '$_root' does not exist" >&2
    return 2
  fi

  existing_dynamic_fs_roots+=("$_root")

  # Copy in procfs and devfs -- this is a security hole, but so's building
  # as root
  if [[ ! -d "$_root/proc" ]]
  then
    mkdir "$_root/proc"
    chmod 555 "$_root/proc"
  fi
  mount --bind /proc "$_root/proc"
  if [[ ! -d "$_root/dev" ]]
  then
    mkdir "$_root/dev"
    chmod 555 "$_root/dev"
  fi
  mount --bind /dev "$_root/dev"

  # Ubuntu keeps shared memory in /run/shm instead of /dev/shm.
  # /dev/shm winds up being a symlink to /run/shm.  Ugh.
  # Not having this bindmount causes an issue with Python's multiprocessing
  # module on Ubuntu which emits an error pointing to this issue:
  #   http://bugs.python.org/issue3770
  # The following somewhat helped clue me in to the root cause:
  #   http://stackoverflow.com/a/2009505
  #   http://stackoverflow.com/q/6033599
  if [[ -d "/run/shm" ]]
  then
    if [[ ! -d "$_root/run/shm" ]]
    then
      mkdir -p "$_root/run/shm"
      chmod 777 "$_root/run/shm"
    fi
    mount --bind /run/shm "$_root/run/shm"
  fi

  "$(DIR)/create_resolv.sh" > "$_root/etc/resolv.conf"

  # Hilariously, dart cannot network if /etc/hosts is missing.  Not
  # having /etc/hosts present causes the following error during its
  # build:
  #
  #     Transformer library "package:initialize/build/loader_replacer.dart"
  #     not found.
  #
  # This flaw almost certainly extends to other packages... so we'll manually
  # populate /etc/hosts just in case no package overwrites it.  This fixes
  # the issue on Ubuntu, where base-ubuntu does not actually contain an
  # /etc/hosts file for some reason...
  if [[ ! -e "$_root/etc/hosts" ]]
  then
    echo "127.0.0.1 localhost" > "$_root/etc/hosts"
  fi
}

depopulate_dynamic_fs_pieces()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <chroot_to_depopulate>" >&2
    return 1
  fi
  local _root="$1"

  if [[ ! -d "$_root" ]]
  then
    echo "${FUNCNAME[0]}: target chroot '$_root' does not exist" >&2
    return 2
  fi

  existing_dynamic_fs_roots=("${existing_dynamic_fs_roots[@]/$_root}")

  umount "$_root/proc"
  umount "$_root/dev"
  if [[ -d "$_root/run/shm" ]]
  then
    umount "$_root/run/shm"
  fi

  rm -f "$_root/etc/resolv.conf"
}

dont_depopulate_dynamic_fs_pieces()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <chroot_to_depopulate>" >&2
    return 1
  fi
  local _root="$1"

  existing_dynamic_fs_roots=("${existing_dynamic_fs_roots[@]/$_root}")
}

cleanup_dynamic_fs_roots()
{
  local _root=""
  for _root in "${existing_dynamic_fs_roots[@]}"
  do
    if [[ -z "$_root" ]]
    then
      continue
    fi

    local _retval=0
    depopulate_dynamic_fs_pieces "$_root" || _retval=$?
    if (( "$_retval" ))
    then
      echo "${FUNCNAME[0]}: failed to clean up '$_root'" >&2
      continue
    fi
  done
}

# This needs to run sooner than the file cleanup handlers,
# as the file cleanup handlers may attempt to clean up the
# procfs/devfs filesystems, which may blow up our host system
# (!!)
register_exit_handler_front cleanup_dynamic_fs_roots

# Creates a new bare RPM root.
#
# Will sometimes retrieve files from cache, to avoid hammering
# upstream package mirrors.
mkroot()
{
  if (( "$#" < 1 || "$#" > 2 )) && [[ ! -z "$2" || "$2" != "--no-repo" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <env_var_to_store_dir_in> [--no-repo]"
    return 1
  fi
  local _env="$1"

  # TODO: Check if $(DIR) is correct after other source files
  #       are imported :X
  if [[ -d "$(DIR)/cache/baseroot" && "$2" != "--no-repo" ]]
  then
    echo "${FUNCNAME[0]}: creating root from baseroot cache" >&2
    make_temp_dir "$_env"
    cp -r "$(DIR)/cache/baseroot/"* "${!_env}"
    populate_dynamic_fs_pieces "${!_env}"
    return 0
  fi

  echo "${FUNCNAME[0]}: creating root from packages" >&2
  if [[ "$2" == "--no-repo" ]]
  then
    create_bare_root "$_env" --no-repo
  else
    create_bare_root "$_env"
    if [[ ! -e "$(DIR)/cache" ]]
    then
      mkdir -pv "$(DIR)/cache"
    fi
    cp -r "${!_env}" "$(DIR)/cache/baseroot"
  fi
  populate_dynamic_fs_pieces "${!_env}"
}

# Removes root cleanly.
rmroot()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <root_to_remove>" >&2
    return 1
  fi
  local _root="$1"

  depopulate_dynamic_fs_pieces "$_root"
  rm -rf "$_root"
  unregister_temp_file "$_root"
}
