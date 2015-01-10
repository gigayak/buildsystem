#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/escape.sh"

test_sq()
{
  local desc="$1"
  local input="$2"
  local want="$3"

  local got="$(sq "$input")"
  if [[ "$got" != "$want" ]]
  then
    echo "FAIL: test_sq: got $got, want $want"
  else
    echo "PASS: test_sq: got $got, want $want"
  fi
}

test_sq "basic case not requiring quoting" "lalala" "'lalala'" 
test_sq "basic case with single quote" "lala'la" "'lala'\"'\"'la'"
