#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
make_temp_dir tmp
repo="$tmp/repo"
mkdir -pv "$repo"
cat > "$tmp/test_config.sh" <<EOF
set_config DOMAIN test.example.com
set_config REPO_LOCAL_PATH $(sq "$repo")
set_config REPO_URL ''
EOF
export YAK_TEST_CONFIG="$tmp/test_config.sh"

failures=0

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
    failures="$(expr "$failures" + 1)"
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
    failures="$(expr "$failures" + 1)"
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


arch="$("$(DIR)/os_info.sh" --architecture)"
test_pkg_success test just-version
ensure_exists "${arch}-test:just-version"

if (( "$failures" ))
then
  echo "$(basename "$0"): $failures tests failed" >&2
  exit 1
fi
echo "$(basename "$0"): all tests passed" >&2
