#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

if [[ ! -z "$_NET_SH_INCLUDED" ]]
then
  return 0
fi
_NET_SH_INCLUDED=1

source "$(DIR)/log.sh"

# This file contains utility functions for handling network-related stuff
# such as IP address manipulation.

ip_to_dec()
{
  local _ip="$1"
  if [[ -z "$_ip" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <ip>" >&2
    echo >&2
    echo "Returns the decimal representation of the IP provided." >&2
    return 1
  fi
  local _ipa="$(echo "$_ip" \
    | sed -nre 's@^([0-9]+)\.[0-9]+\.[0-9]+\.[0-9]+$@\1@gp')"
  if [[ -z "$_ipa" ]] || (( "$_ipa" < 0 || "$_ipa" >= 256 ))
  then
    log_rote "failed to parse byte 1 of IP '$_ip'"
    return 1
  fi
  local _ipb="$(echo "$_ip" \
    | sed -nre 's@^[0-9]+\.([0-9]+)\.[0-9]+\.[0-9]+$@\1@gp')"
  if [[ -z "$_ipb" ]] || (( "$_ipb" < 0 || "$_ipb" >= 256 ))
  then
    log_rote "failed to parse byte 2 of IP '$_ip'"
    return 1
  fi
  local _ipc="$(echo "$_ip" \
    | sed -nre 's@^[0-9]+\.[0-9]+\.([0-9]+)\.[0-9]+$@\1@gp')"
  if [[ -z "$_ipc" ]] || (( "$_ipc" < 0 || "$_ipc" >= 256 ))
  then
    log_rote "failed to parse byte 3 of IP '$_ip'"
    return 1
  fi
  local _ipd="$(echo "$_ip" \
    | sed -nre 's@^[0-9]+\.[0-9]+\.[0-9]+\.([0-9]+)$@\1@gp')"
  if [[ -z "$_ipd" ]] || (( "$_ipd" < 0 || "$_ipd" >= 256 ))
  then
    log_rote "failed to parse byte 4 of IP '$_ip'"
    return 1
  fi
  local _dec="$(echo "$_ipa*2^24 + $_ipb*2^16 + $_ipc*2^8 + $_ipd*2^0" | bc)"
  if [[ -z "$_dec" ]]
  then
    log_rote "failed to convert IP '$_ip' to decimal"
    return 1
  fi
  echo "$_dec"
}

dec_to_ip()
{
  local _dec="$1"
  if [[ -z "$_dec" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <ip in decimal form>" >&2
    return 1
  fi
  if ! echo "$_dec" | grep -E '^[0-9]+$' >/dev/null 2>&1
  then
    log_error "input '$_dec' does not appear to be integer"
    return 1
  fi
  if (( "$_dec" < 0 || "$_dec" >= 4294967296 ))
  then
    log_error "input '$_dec' outside of valid 4-byte unsigned integer range"
    return 1
  fi
  local _ipa="$(echo "$_dec / 2^24" | bc)"
  if [[ -z "$_ipa" ]]
  then
    log_error "failed to convert byte 1 of IP '$_dec'"
    return 1
  fi
  local _ipb="$(echo "$_dec / 2^16 % 256" | bc)"
  if [[ -z "$_ipb" ]]
  then
    log_error "failed to convert byte 2 of IP '$_dec'"
    return 1
  fi
  local _ipc="$(echo "$_dec / 2^8 % 256" | bc)"
  if [[ -z "$_ipc" ]]
  then
    log_error "failed to convert byte 3 of IP '$_dec'"
    return 1
  fi
  local _ipd="$(echo "$_dec / 2^0 % 256" | bc)"
  if [[ -z "$_ipd" ]]
  then
    log_error "failed to convert byte 4 of IP '$_dec'"
    return 1
  fi
  echo "$_ipa.$_ipb.$_ipc.$_ipd"
}


parse_subnet_start()
{
  local subnet="$1"
  if (( "$#" != 1 )) || [[ -z "$subnet" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <subnet specification>" >&2
    echo >&2
    echo "Returns IP portion of subnet specification." >&2
    echo "For example, 192.168.122.0 for 192.168.122.0/24." >&2
    return 1
  fi
  local subnet_start="$(echo "$subnet" \
    | sed -nre 's@^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/[1-9][0-9]*$@\1@gp')"
  if [[ -z "$subnet_start" ]]
  then
    log_error "failed to parse subnet start from '$subnet'"
    return 1
  fi
  echo "$subnet_start"
}

parse_subnet_start_dec()
{
  local retval=0
  local start
  start="$(parse_subnet_start "$@")" || retval=$?
  if (( "$retval" )) || [[ -z "$start" ]]
  then
    log_error "failed to parse subnet $@"
    return 1
  fi
  echo "$(ip_to_dec "$start")"
}

parse_subnet_size()
{
  local subnet="$1"
  if (( "$#" != 1 )) || [[ -z "$subnet" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <subnet specification>" >&2
    echo >&2
    echo "Returns size portion of subnet specification." >&2
    echo "For example, 24 for 192.168.122.0/24." >&2
    return 1
  fi
  subnet_size="$(echo "$subnet" \
    | sed -nre 's@^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/([1-9][0-9]*)$@\1@gp')"
  if [[ -z "$subnet_size" ]]
  then
    log_error "failed to parse subnet size from '$subnet'"
    return 1
  fi
  echo "$subnet_size"
}

parse_subnet_size_dec()
{
  local retval=0
  local size
  size="$(parse_subnet_size "$@")" || retval=$?
  if (( "$retval" )) || [[ -z "$size" ]]
  then
    log_error "failed to parse subnet $@"
    return 1
  fi
  echo "2^(32-$size)" | bc || retval=$?
  if (( "$retval" ))
  then
    log_error "failed to convert size $size to number of IPs"
    return 1
  fi
}

size_to_mask()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <number of bits>" >&2
    echo >&2
    echo "Returns subnet mask a la 255.255.255.0" >&2
    return 1
  fi
  local size="$1"
  if ! echo "$size" | grep -E '^[0-9]+$' >/dev/null 2>&1
  then
    log_error "received non-integer subnet mask size"
    return 1
  fi
  if (( "$size" < 0 || "$size" > 32 ))
  then
    log_error "subnet masks should be between 0 and 32 bits"
    return 1
  fi
  local mask_dec
  mask_dec="$(echo "2^32 - 2^(32-$size)" | bc)"
  dec_to_ip "$mask_dec"
}

mask_to_size()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <subnet mask>" >&2
    echo >&2
    echo "Returns mask size - for example, '24' for '255.255.255.0'." >&2
    return 1
  fi
  local mask="$1"
  # TODO: Deal with nasty brute-force approach used here.  This code isn't
  # going to be used anywhere performance-intensive yet, and it needs to be
  # written with some ubiquitous shell utility - and bc wants to deal with
  # floats when logarithms are used, which complicates figuring out which
  # inputs are invalid (i.e. 255.255.255.253, which is in between /30 and /31).
  # This will work for light-duty applications, and has correct behavior in the
  # face of invalid input - so it stays despite hackiness.
  local size
  for size in $(seq 0 32)
  do
    local current_mask
    current_mask="$(size_to_mask "$size")"
    if [[ "$current_mask" == "$mask" ]]
    then
      echo "$size"
      return 0
    fi
  done
  log_error "'$mask' is not a valid subnet mask"
  return 1
}

random_ip_dec()
{
  local _start="$1"
  local _end="$2"
  if (( "$#" != 2 )) || [[ -z "$_start" || -z "$_end" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <start IP in decimal> <end IP in decimal>" >&2
    echo >&2
    echo "Returns an IP within inclusive range that begins at start IP and" >&2
    echo "ends at end IP.  For example, ${FUNCNAME[0]} 1 1 returns 1 every" >&2
    echo "time, while ${FUNCNAME[0]} 1 3 will return 1, 2, or 3." >&2
    return 1
  fi
  if (( "$_start" == "$_end" ))
  then
    echo "$_start"
    return 0
  fi
  echo "$_start + ($RANDOM*32768 + $RANDOM) % ($_end - $_start)" | bc
}

random_ip()
{
  if (( "$#" != 1 )) || [[ -z "$1" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <subnet specification>" >&2
    echo >&2
    echo "Returns a random IP within the given subnet, while taking care" >&2
    echo "to avoid the broadcast address, the subnet identifier (i.e." >&2
    echo "10.0.0.0 for 10.0.0.0/8), and the first valid IP in the subnet" >&2
    echo "(i.e. 10.0.0.1 for 10.0.0.0/8)." >&2
    echo >&2
    echo "Does not pay any attention to which IPs may already be in use." >&2
    echo "Only use this function in scripts that add that awareness." >&2
    return 1
  fi
  local _subnet="$1"
  # Determine range of valid IPs we can choose from.
  local subnet_start_dec
  subnet_start_dec="$(parse_subnet_start_dec "$_subnet")"
  local subnet_size_dec
  subnet_size_dec="$(parse_subnet_size_dec "$_subnet")"

  # Advance by 2 reserved IPs: first IP is reserved as network identifier,
  # second is reserved (by convention only) for a default gateway.
  local valid_start_dec
  valid_start_dec="$(echo "$subnet_start_dec + 2" | bc)"
  # -1 here is because the size includes the IP at subnet_start
  local subnet_end_dec
  subnet_end_dec="$(echo "$subnet_start_dec + $subnet_size_dec - 1" | bc)"
  # Retreat by 1 reserved IP: last IP is reserved as broadcast address.
  local valid_end_dec
  valid_end_dec="$(echo "$subnet_end_dec - 1" | bc)"
  if (( "$valid_end_dec" < "$valid_start_dec" ))
  then
    log_error "end of generation range precedes start of range"
    log_rote "range was [$valid_start_dec, $valid_end_dec]"
    return 1
  fi
  local retval
  local ip
  ip="$(random_ip_dec "$valid_start_dec" "$valid_end_dec")" || retval=$?
  if (( "$retval" ))
  then
    log_error "failed to generate a random IP"
    log_rote "range was [$valid_start_dec, $valid_end_dec]"
    return 1
  fi
  dec_to_ip "$ip"
}
