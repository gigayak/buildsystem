# /bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -z "$_MKROOT_SH_INCLUDED" ]]
then
  return 0
fi
_MKROOT_SH_INCLUDED=1
source "$DIR/cleanup.sh"
source "$DIR/arch.sh"

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
  if (( "$#" < 1 || "$#" > 2 )) || [[ ! -z "$2" && "$2" != "--no-repo" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <env_var_to_store_dir_in> [--no-repo]" >&2
    return 1
  fi
  local env="$1"
  local _flag="$2"

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
  local _pkg
  for _pkg in rpm-build centos-release yum
  do
    echo "${FUNCNAME[0]}: installing $_pkg" >&2
    "$DIR/install_pkg.sh" --install_root="$_root" --pkg_name="$_pkg"
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
  mount --bind /proc "$_root/proc"
  mount --bind /dev "$_root/dev"

  # Choose which resolv.conf to populate.  We have two: one with a public DNS
  # server which we can fail over onto if our DNS servers are down, and a much
  # more mainstream one which points to our internal DNS servers.  This check
  # should ensure that we populate resolv.conf with internal DNS servers unless
  # they are not available.
  local _resolv_src="$DIR/resolv.conf.nodns.tpl"
  local _dns_ip
  while read -r _dns_ip
  do
    if ping -c 1 "$_dns_ip" >/dev/null 2>&1
    then
      _resolv_src="$DIR/resolv.conf.tpl"
    fi
  done \
  < <(grep -E -e '^nameserver' "$DIR/resolv.conf.tpl" | awk '{print $2}')

  # Copy in our resolv.conf -- this may be a point of breakage
  cp "$_resolv_src" "$_root/etc/resolv.conf"
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

  # TODO: Check if $DIR is correct after other source files
  #       are imported :X
  echo "${FUNCNAME[0]}: cached base root is temporarily disabled" >&2
  echo "${FUNCNAME[0]}: see mkroot.sh for more details" >&2
  if [[ -d "$DIR/cache/baseroot" && "$2" != "--no-repo" ]]
  then
    make_temp_dir "$_env"
    cp -r "$DIR/cache/baseroot/"* "${!_env}"
    populate_dynamic_fs_pieces "${!_env}"
    return 0
  fi

  if [[ "$2" == "--no-repo" ]]
  then
    create_bare_root "$_env" --no-repo
  else
    create_bare_root "$_env"
    if [[ ! -e "$DIR/cache" ]]
    then
      mkdir -pv "$DIR/cache"
    fi
    cp -r "${!_env}" "$DIR/cache/baseroot"
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
