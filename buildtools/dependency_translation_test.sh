#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/dependency_translation.sh"

failures=0

test_case()
{
  name="$1"
  got="$2"
  want="$3"
  if [[ "$got" == "$want" ]]
  then
    echo "PASS: $name"
  else
    failures="$(expr "$failures" + 1)"
    echo "FAIL: $name"
    echo "  got: $got" >&2
    echo "  want: $want" >&2
  fi
}

export YAK_TARGET_OS=''
export YAK_TARGET_ARCH=''
test_case "base case" \
  "$(dep --arch=arch --distro=distro testpkg)" \
  "arch-distro:testpkg"

export YAK_TARGET_OS=distro
export YAK_TARGET_ARCH=arch
test_case "explicitly local case" \
  "$(dep --arch=arch --distro=distro testpkg)" \
  "testpkg"

test_case "implicitly local case" \
  "$(dep testpkg)" \
  "testpkg"

test_case "case insensitive local case" \
  "$(dep --arch=ARCH --distro=DISTRO TESTPKG)" \
  "testpkg"

test_case "case insensitive foreign case" \
  "$(dep --arch=OTHER_ARCH --distro=OTHER_DISTRO TESTPKG)" \
  "other_arch-other_distro:testpkg"

test_case "case insensitive foreign translation case" \
  "$(dep --arch=ARCH --distro=TEST TEST_SINGLE_OUT_PKG)" \
  "arch-test:test_single_out_translation"

test_case "case insensitive foreign deletion case" \
  "$(dep --arch=ARCH --distro=TEST TEST_DELETION_PKG)" \
  ""

test_case "case insensitive foreign expansion case" \
  "$(dep --arch=ARCH --distro=TEST TEST_EXPANSION_PKG)" \
  "$(echo arch-test:first_out; echo arch-test:second_out)"

exit "$failures"
