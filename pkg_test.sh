#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

failures=0

build_pkg()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <pkg_name>" >&2
    return 1
  fi
  pkg_name="$1"

  "$(DIR)/pkg.from_name.sh" \
    --target_distribution=test \
    --pkg_name="$pkg_name" \
    >&2 \
    || return $?
  return 0
}

test_pkg_success()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <pkg_name>" >&2
    return 1
  fi
  pkg_name="$1"

  retval=0
  build_pkg "$pkg_name" \
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
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <pkg_name>" >&2
    return 1
  fi
  pkg_name="$1"

  retval=0
  build_pkg "$pkg_name" \
    || retval=$?
  if (( "$retval" ))
  then
    echo "PASS: building $pkg_name failed as expected"
  else
    echo "FAIL: building $pkg_name succeeded (expected failure)"
    failures="$(expr "$failures" + 1)"
  fi
}

test_pkg_success just-version

if (( "$failures" ))
then
  echo "$(basename "$0"): $failures tests failed" >&2
  exit 1
fi
echo "$(basename "$0"): all tests passed" >&2
