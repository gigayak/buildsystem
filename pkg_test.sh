#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"

add_flag --boolean preserve_chroot "Set to keep chroot around for debugging."
parse_flags "$@"

make_temp_dir tmp
repo="$tmp/repo"
mkdir -pv "$repo"
bin="$tmp/bin"
mkdir -pv "$bin"
ln -sv "$(DIR)/test_stubs/apt_cache.sh" "$bin/apt-cache"
ln -sv "$(DIR)/test_stubs/apt_get.sh" "$bin/apt-get"
ln -sv "$(DIR)/test_stubs/dpkg.sh" "$bin/dpkg"
cat > "$tmp/test_config.sh" <<EOF
set_config DOMAIN test.example.com
set_config REPO_LOCAL_PATH $(sq "$repo")
set_config REPO_URL 'https://repo.test.example.com'
path_prepend /.build_workspace/buildsystem/test_stubs/bin
path_prepend $(sq "$bin")
EOF
export YAK_TEST_CONFIG="$tmp/test_config.sh"

build_pkg()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <distro> <pkg_name>" >&2
    return 1
  fi
  distro="$1"
  pkg_name="$2"

  "$(DIR)/pkg.from_name.sh" \
    --target_distribution="$distro" \
    --pkg_name="$pkg_name" \
    >&2 \
    || return $?
  return 0
}

test_pkg_success()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <distro> <pkg_name>" >&2
    return 1
  fi
  distro="$1"
  pkg_name="$2"

  retval=0
  build_pkg "$distro" "$pkg_name" \
    || retval=$?
  if (( ! "$retval" ))
  then
    echo "PASS: building $pkg_name was successful"
  else
    echo "FAIL: building $pkg_name failed (expected success)"
  fi
}

test_pkg_failure()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <distro> <pkg_name>" >&2
    return 1
  fi
  distro="$1"
  pkg_name="$2"

  retval=0
  build_pkg "$distro" "$pkg_name" \
    || retval=$?
  if (( "$retval" ))
  then
    echo "PASS: building $pkg_name failed as expected"
  else
    echo "FAIL: building $pkg_name succeeded (expected failure)"
  fi
}

ensure_exists()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <fully qualified pkg name>" >&2
    return 1
  fi
  pkg="$1"

  if [[ -e "${repo}/${pkg}.done" ]]
  then
    echo "PASS: package $(sq "$pkg") exists as expected"
  else
    echo "FAIL: package $(sq "$pkg") does not exist (expected existence)"
  fi
}

create_dummy_package()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <fully qualified pkg name>" >&2
    return 1
  fi
  pkg="$1"
  basename="${repo}/${pkg}"
  if [[ -e "${basename}.done" ]]
  then
    echo "${FUNCNAME[0]}: package '$pkg' already exists" >&2
    return 1
  fi
  echo "1.0" > "${basename}.version"
  touch "${basename}.dependencies"
  tar -c -T /dev/null -z -f "${basename}.tar.gz"
  touch "${basename}.done"
}

ensure_depends()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <fully qualified pkg name> <dependency>" >&2
    return 1
  fi
  pkg="$1"
  dep="$2"
  basename="${repo}/${pkg}"
  grep -E "^$dep\$" "${basename}.dependencies" >/dev/null 2>&1 \
    && echo "PASS: package $(sq "$pkg") depends on $(sq "$dep")" \
    || echo "FAIL: package $(sq "$pkg") missing dep $(sq "$dep")"
}

arch="$("$(DIR)/os_info.sh" --architecture)"

# Simplest package build possible: just a version specification.
#
# If this fails, then there is something fundamentally wrong with the
# entire buildsystem.
test_pkg_success test just-version
ensure_exists "${arch}-test:just-version"

# All apt-conversion packages rely on this package through apt.builddeps.sh.
#
# Installing the real one takes a long time, so we'll just create an empty
# package with no dependencies for testing purposes.
create_dummy_package "${arch}-ubuntu:base-ubuntu"

# Simple directed acyclic graph of concrete dependencies to traverse.
#
# a depends on b, c, and d.
test_pkg_success ubuntu simple-dag-a
ensure_exists "${arch}-ubuntu:simple-dag-a"
ensure_depends "${arch}-ubuntu:simple-dag-a" "simple-dag-b"
ensure_depends "${arch}-ubuntu:simple-dag-a" "simple-dag-c"
ensure_depends "${arch}-ubuntu:simple-dag-a" "simple-dag-d"
ensure_exists "${arch}-ubuntu:simple-dag-b"
ensure_exists "${arch}-ubuntu:simple-dag-c"
ensure_exists "${arch}-ubuntu:simple-dag-d"

if (( "$F_preserve_chroot" ))
then
  unregister_temp_file "$tmp"
  echo "$(basename "$0"): saved $(sq "$tmp") for inspection." >&2
fi
