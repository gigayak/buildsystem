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

# Check basic function of required flags.
(
  source "$(DIR)/flag.sh"
  add_flag --required req_flag "required flag"
  _program_name="test_required_flag_omitted"
  _program_params=()
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_failure "$retval" "failing to pass required flag"
)

(
  source "$(DIR)/flag.sh"
  add_flag --required req_flag "required flag"
  _program_name="test_required_flag_provided"
  _program_params=("--req_flag=wat")
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "properly provided required flag"
)

# Basic functionality of boolean flags.
(
  source "$(DIR)/flag.sh"
  add_flag --boolean bool_flag "boolean flag"
  _program_name="test_boolean_flag_true"
  _program_params=("--bool_flag")
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "properly provided boolean flag"
  (( "$F_bool_flag" )) || retval=$?
  expect_success "$retval" "boolean flag evaluates true when present"
)

(
  source "$(DIR)/flag.sh"
  add_flag --boolean bool_flag "boolean flag"
  _program_name="test_boolean_flag_true"
  _program_params=()
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "properly provided boolean flag"
  (( ! "$F_bool_flag" )) || retval=$?
  expect_success "$retval" "boolean flag evaluates false when missing"
)

# Check unknown flag.
(
  source "$(DIR)/flag.sh"
  _program_name="test_unknown_flag"
  _program_params=("--unknown=die")
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_failure "$retval" "passing unknown flag"
)

# Check array functionality.
(
  source "$(DIR)/flag.sh"
  add_flag --array a "array flag"
  _program_name="test_array"
  _program_params=("--a=wat" "--a=two" "--a=three")
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "parsing array flags"
  retval=0
  (( "${#F_a[@]}" == "3" )) || retval=$?
  expect_success "$retval" "retrieving array flags"
)

# Check that defaults are populated.
(
  source "$(DIR)/flag.sh"
  add_flag --default="wat" d "flag with default"
  _program_name="test_default"
  _program_params=()
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "parsing flags with default substitution"
  retval=0
  [[ "${F_d}" == "wat" ]] || retval=$?
  expect_success "$retval" "retrieving default-substituted flag"
)

# Check that defaults are overridden.
(
  source "$(DIR)/flag.sh"
  add_flag --default="wat" d "flag with default"
  _program_name="test_default"
  _program_params=("--d=nope")
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "parsing flags with default override"
  retval=0
  [[ "${F_d}" == "nope" ]] || retval=$?
  expect_success "$retval" "retrieving default-overridden flag"
)

# Check that defaults are overridden, even with a null.
(
  source "$(DIR)/flag.sh"
  add_flag --default="wat" d "flag with default"
  _program_name="test_default"
  _program_params=("--d=")
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "parsing flags with null default override"
  retval=0
  [[ "${F_d}" == "" ]] || retval=$?
  expect_success "$retval" "retrieving null default-overridden flag"
)

# Check that nothing after -- is parsed.
(
  source "$(DIR)/flag.sh"
  _program_name="test_default"
  _program_params=("--" "--test_flag")
  retval=0
  parse_flags "${_program_params[@]}" || retval=$?
  expect_success "$retval" "ceasing parsing at -- delimiter"
  retval=0
  (( "${#ARGS[@]}" == 1 )) || retval=$?
  expect_success "$retval" "checking number of args after -- delimiter"
  [[ "${ARGS[0]}" == "--test_flag" ]] || retval=$?
  expect_success "$retval" "checking value of arg after -- delimiter"
)

# Check that multiple functions can use flags.
(
  source "$(DIR)/flag.sh"
  func1()
  {
    add_flag --default="wat" d "flag with default"
    parse_flags "$@" || return 2
    if [[ "$F_d" != "wat" ]]
    then
      return 1
    fi
    return 0
  }
  retval=0
  func1 || retval=$?
  expect_success "$retval" "checking flag defaults inside function"
  retval=0
  func1 --d="nope" || retval=$?
  expect_failure "$retval" "checking flag default override inside function"

  func2()
  {
    add_flag --required r "flag with requirement"
    parse_flags "$@" || return 2
    if [[ "$F_r" != "yes" ]]
    then
      return 1
    fi
    return 0
  }
  retval=0
  func2 || retval=$?
  expect_failure "$retval" "checking required flag missing inside function"
  retval=0
  func2 --r "yes" || retval=$?
  expect_success "$retval" "checking required flag present inside function"

  func3()
  {
    add_flag --default="" d "flag with same name as func1"
    parse_flags "$@" || return 2
    if [[ ! -z "$F_d" ]]
    then
      return 1
    fi
    return 0
  }
  retval=0
  func3 || retval=$?
  expect_success "$retval" \
    "checking flag with same name as other function doesn't leak"
  retval=0
  func3 --d="will fail" || retval=$?
  expect_failure "$retval" \
    "checking flag with same name as other function functions"
)
