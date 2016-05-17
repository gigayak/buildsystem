#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/log.sh"

got=""
want=""
desc=""

compare()
{
  if [[ "$got" == "$want" ]]
  then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc (got '$got', want '$want')"
  fi
}

got="$(log_rote "single argument" 2>&1)"
want="R${$}[log_test.sh] main: single argument"
desc="single argument"
compare

got="$(log_rote two arguments 2>&1)"
want="R${$}[log_test.sh] main: two arguments"
desc="two arguments"
compare

got="$(log_rote "level test" 2>&1)"
want="R${$}[log_test.sh] main: level test"
desc="ROTE level logging"
compare

got="$(log_warn "level test" 2>&1)"
want="W${$}[log_test.sh] main: level test"
desc="WARN level logging"
compare

got="$(log_error "level test" 2>&1)"
want="E${$}[log_test.sh] main: level test"
desc="ERROR level logging"
compare
