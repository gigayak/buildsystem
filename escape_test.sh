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
    echo "FAIL: ${FUNCNAME[0]}: $desc: got $got, want $want"
  else
    echo "PASS: ${FUNCNAME[0]}: $desc"
  fi
}

test_sq "basic case not requiring quoting" "lalala" "'lalala'" 
test_sq "basic case with single quote" "lala'la" "'lala'\"'\"'la'"

test_re()
{
  local desc="$1"
  local input="$2"
  local want="$3"

  local got="$(grep_escape "$input")"
  if [[ "$got" != "$want" ]]
  then
    echo "FAIL: ${FUNCNAME[0]}: $desc: got $got, want $want"
  else
    echo "PASS: ${FUNCNAME[0]}: $desc"
  fi
}

test_re "basic case not requiring escaping" "abc" "abc"
test_re "repetition escapes" '.+*{}' '\.\+\*\{\}'
test_re "paren escapes" '()' '\(\)'
test_re "class escapes" '[]' '\[\]'
test_re "beginning / end of line escapes" '^$' '\^\$'
test_re "escape escapes" '\' '\\'
