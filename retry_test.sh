#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

pass()
{
  echo "PASS: $1"
}
fail()
{
  echo "FAIL: $1"
}
expect_failure()
{
  retval="$1"
  name="${FUNCNAME[0]}: $2"
  if (( "$retval" ))
  then
    pass "$name"
  else
    fail "$name"
  fi
}
expect_success()
{
  retval="$1"
  name="${FUNCNAME[0]}: $2"
  if (( "$retval" ))
  then
    fail "$name"
  else
    pass "$name"
  fi
}

(
  source "$(DIR)/retry.sh"
  retval=0
  retryable return 0 || retval=$?
  expect_success "$retval" "consistent success"
)

(
  source "$(DIR)/retry.sh"
  retval=0
  retryable return 1 || retval=$?
  expect_failure "$retval" "consistent failure"
)
