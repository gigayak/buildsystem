#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# Check basic function of required flags.
(
  source "$DIR/flag.sh"
  add_flag --required req_flag "required flag"
  _program_name="test_required_flag_omitted"
  _program_params=("$_program_name")
  retval=0
  parse_flags || retval=$?
  expect_failure "$retval" "failing to pass required flag"
)

(
  source "$DIR/flag.sh"
  add_flag --required req_flag "required flag"
  _program_name="test_required_flag_provided"
  _program_params=("$_program_name" "--req_flag=wat")
  retval=0
  parse_flags || retval=$?
  expect_success "$retval" "properly provided required flag"
)

# Check unknown flag.
(
  source "$DIR/flag.sh"
  _program_name="test_unknown_flag"
  _program_params=("$_program_name" "--unknown=die")
  retval=0
  parse_flags || retval=$?
  expect_failure "$retval" "passing unknown flag"
)

# Check array functionality.
(
  source "$DIR/flag.sh"
  add_flag --array a "array flag"
  _program_name="test_array"
  _program_params=("$_program_name" "--a=wat" "--a=two" "--a=three")
  retval=0
  parse_flags || retval=$?
  expect_success "$retval" "parsing array flags"
  retval=0
  (( "${#F_a[@]}" == "3" )) || retval=$?
  expect_success "$retval" "retrieving array flags"
)


