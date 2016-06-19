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
expect()
{
  if [[ "$1" != "$2" ]]
  then
    fail "$3 (got '$1', want '$2')"
  else
    pass "$3"
  fi
}

source "$(DIR)/net.sh"


# Tests for IP conversions

ip_dec_pair()
{
  expect "$(ip_to_dec "$1")" "$2" "converting $1 to decimal"
  expect "$(dec_to_ip "$2")" "$1" "converting $1 from decimal"
}
ip_dec_pair "127.0.0.1" "2130706433"
ip_dec_pair "1.2.3.4" "16909060"
# boundary values
ip_dec_pair "255.255.255.255" "4294967295"
ip_dec_pair "0.0.0.0" "0"

for invalid_ip in \
  "256.255.255.255" \
  "255.256.255.255" \
  "255.255.256.255" \
  "255.255.255.256" \
  "a.b.c.d" \
  "0.-1.0.0" \
  "1.2.3.4.5"
do
  desc="converting invalid IP $invalid_ip to decimal should abort"
  if ! ip_to_dec "$invalid_ip" >/dev/null 2>&1
  then
    pass "$desc"
  else
    fail "$desc"
  fi
done
for invalid_dec in "-1" "4294967296" "0.0" "0.000" "1e3" "forty-two" "."
do
  desc="converting invalid IP from decimal $invalid_dec should abort"
  if ! dec_to_ip "$invalid_dec" >/dev/null 2>&1
  then
    pass "$desc"
  else
    fail "$desc"
  fi
done


# Tests for subnet manipulation

subnet_to_parse()
{
  subnet="$1"
  start="$2"
  size="$3"
  start_dec="$4"
  size_dec="$5"
  expect "$(parse_subnet_start "$subnet")" "$start" \
    "parsing logical start of validly-formatted subnet $subnet"
  expect "$(parse_subnet_start_dec "$subnet")" "$start_dec" \
    "parsing decimal start of validly-formatted subnet $subnet"
  expect "$(parse_subnet_size "$subnet")" "$size" \
    "parsing logical size of validly-formatted subnet $subnet"
  expect "$(parse_subnet_size_dec "$subnet")" "$size_dec" \
    "parsing decimal size of validly-formatted subnet $subnet"
}
subnet_to_parse "192.168.122.0/24" "192.168.122.0" "24" "3232266752" "256"
subnet_to_parse "10.0.0.0/8" "10.0.0.0" "8" "167772160" "16777216"
subnet_to_parse "0.0.0.0/8" "0.0.0.0" "8" "0" "16777216"

for invalid_subnet in "asdf/8" "1/1" "0.0.0.0.0/16"
do
  for func in \
    parse_subnet_start parse_subnet_start_dec \
    parse_subnet_size parse_subnet_size_dec
  do
    desc="$func on invalid subnet $invalid_subnet should abort"
    retval=0
    ret="$("$func" "$invalid_subnet" 2>/dev/null)" || retval=$?
    if (( "$retval" ))
    then
      pass "$desc"
    else
      fail "$desc (got unexpected output '$ret')"
    fi
  done
done

mask_to_parse()
{
  bits="$1"
  mask="$2"
  expect "$(size_to_mask "$bits")" "$mask" \
    "converting subnet size /$bits to mask $mask"
  expect "$(mask_to_size "$mask")" "$bits" \
    "converting subnet mask $mask to size /$bits"
}
mask_to_parse "32" "255.255.255.255"
mask_to_parse "30" "255.255.255.252"
mask_to_parse "24" "255.255.255.0"
mask_to_parse "8" "255.0.0.0"
mask_to_parse "0" "0.0.0.0"
for invalid_size in "-1" "33" "1.1" "1e1" "strings"
do
  desc="converting invalid subnet size /$invalid_size to mask aborts"
  retval=0
  mask="$(size_to_mask "$invalid_size" 2>/dev/null)" || retval=$?
  if (( "$retval" ))
  then
    pass "$desc"
  else
    fail "$desc (got unexpected output '$mask')"
  fi
done
for invalid_mask in "1.2.3.4" "0.0.0.0.0" "0.0.0" "string"
do
  desc="converting invalid subnet mask $invalid_mask to size aborts"
  retval=0
  size="$(mask_to_size "$invalid_mask" 2>/dev/null)" || retval=$?
  if (( "$retval" ))
  then
    pass "$desc"
  else
    fail "$desc (got unexpected output '$size')"
  fi
done

expect "$(random_ip "10.0.0.0/30")" "10.0.0.2" \
  "randomly generating IP in 10.0.0.0/30"
