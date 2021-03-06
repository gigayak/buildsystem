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
source "$(DIR)/log.sh"

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
    log_rote "must be run as root (for chroot)"
    return 1
  fi

  # Create temporary root.
  local _original_dir="$PWD"
  make_temp_dir "$env"
  local _root="${!env}"
  log_rote "made temp dir '$_root'"

  # Populate bare minimum packages to run.
  # TODO: Need a way of determining whether we need i686-tools or just bare OS
  # CentOS host
  # TODO: Check how hard bootstrap on Fedora / Scientific / Redhat would be.
  if which yum >/dev/null 2>&1
  then
    local _pkg
    for _pkg in rpm-build centos-release yum
    do
      "$(DIR)/install_pkg.sh" --install_root="$_root" --pkg_name="$_pkg"
    done
  # Ubuntu host
  elif which apt-get >/dev/null 2>&1
  then
    "$(DIR)/install_pkg.sh" --install_root="$_root" --pkg_name="base-ubuntu"
  # Assuming anything else is a Gigayak host.
  # TODO: Do a secondary check and chuck a wobbly if not on Gigayak here.
  else
    arch="$("$(DIR)/os_info.sh" --architecture)"
    os="$("$(DIR)/os_info.sh" --distribution)"
    # Special case time: when creating an mkroot on a stage2 image, we likely
    # want to build either a tools3 package or a yak package.  When building
    # the first yak package, no other yak packages exist - so fetching yak-bash
    # will be an exercise in futility.  If os_info.sh returned tools2 as the OS
    # in stage2, then yak packages that don't require tools2 explicitly may
    # pull in tools2 packages as dependencies.
    if [[ -e /tools ]]
    then
      os=tools2
    fi

    # Bare minimum to look anything like Linux:
    "$(DIR)/install_pkg.sh" \
      --install_root="$_root" \
      --pkg_name="filesystem-skeleton"
    local _pkgs=()
    # Required to run all build shell scripts:
    _pkgs+=("bash")
    _pkgs+=("bash-aliases")
    _pkgs+=("bash-profile")
    # Brought in by buildtools/tool_names.sh:
    _pkgs+=("coreutils")
    if [[ "$os" == "tools" || "$os" == "tools2" ]]
    then
      _pkgs+=("coreutils-aliases")
    fi
    _pkgs+=("gawk")
    _pkgs+=("grep")
    # Used for getopt by flag.sh:
    _pkgs+=("util-linux")
    # Used by flag.sh:
    _pkgs+=("sed")
    # Used by config.sh:
    _pkgs+=("findutils")
    # Used when installing dependencies directly in dep scripts.
    if [[ "$os" == "tools" || "$os" == "tools2" ]]
    then
      _pkgs+=("stage2-certificate")
    else
      _pkgs+=("stage3-certificate")
    fi
    # Required to look up users.
    _pkgs+=("linux-credentials")
    local _pkg
    for _pkg in "${_pkgs[@]}"
    do
      "$(DIR)/install_pkg.sh" \
        --install_root="$_root" \
        --target_architecture="$arch" \
        --target_distribution="$os" \
        --pkg_name="$_pkg"
    done

    # HACK SCALE: MINOR
    #
    # Install internal certificates and sget only if possible to do so without
    # triggering a recursive build.  Without these being optional, building the
    # certificate authority in create_crypto.sh fails, as the internal
    # certificates package is required by all other packages, but can't be
    # built without the internal certificate authority being initialized... in
    # create_crypto.sh.  This is, of course, a cyclic dependency, so it is
    # broken here.
    #
    # TODO: I'm sure this is a side effect of pkgspecs/*.deps.sh calling
    # install_pkg.sh somewhere.  Removing that dependency should allow this to
    # be removed.
    if "$(DIR)/install_pkg.sh" \
      --install_root="$_root" \
      --target_architecture="$arch" \
      --target_distribution="$os" \
      --pkg_name="internal-ca-certificates" \
      --no_build
    then
      "$(DIR)/install_pkg.sh" \
        --install_root="$_root" \
        --target_architecture="$arch" \
        --target_distribution="$os" \
        --pkg_name=go-sget
    fi
  fi

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
    log_rote "target chroot '$_root' does not exist"
    return 2
  fi

  existing_dynamic_fs_roots+=("$_root")

  # Copy in procfs, devfs, sysfs -- this is a security hole, but so's building
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
  if [[ -d /sys ]]
  then
    if [[ ! -d "$_root/sys" ]]
    then
      mkdir "$_root/sys"
      chmod 555 "$_root/sys"
    fi
    mount --bind /sys "$_root/sys"
  fi

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
    log_rote "target chroot '$_root' does not exist"
    return 2
  fi

  existing_dynamic_fs_roots=("${existing_dynamic_fs_roots[@]/$_root}")

  umount "$_root/proc"
  umount "$_root/dev"
  if [[ -d "$_root/run/shm" ]]
  then
    umount "$_root/run/shm"
  fi
  if [[ -d "$_root/sys" ]]
  then
    umount "$_root/sys"
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
      log_rote "failed to clean up '$_root'"
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
    log_rote "creating root from baseroot cache"
    make_temp_dir "$_env"
    cp -r "$(DIR)/cache/baseroot/"* "${!_env}"
    populate_dynamic_fs_pieces "${!_env}"
    return 0
  fi

  log_rote "creating root from packages"
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
