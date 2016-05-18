#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/config.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_usage_note <<EOF
This is a bit of a shell-based dumb DNS replacement.  DHCP is one of the more
mobile wiggly bits for LXC and qemu across distributions, and tends to be the
result of a custom distribution service.  Doing DHCP in the shell, however
nasty, reduces the number of dependencies we need to have to bootstrap the OS
build on a foreign distribution (like when building on Ubuntu or RHEL).

IP 'leases' are not tied to time, but rather to the topmost resource that the
given network namespace uses - the chroot directory or LXC container.  We do
no automatic reaping of old leases, and instead wait for env_destroy_all.sh to
reclaim them.
EOF

add_flag --required owner "Specify owner of this IP. Format: [chroot|lxc]:<id>"
add_usage_note <<EOF
Example of --owner:
  $(basename "$0") --owner=chroot:/tmp/tmp.Ax4F3B014m
    Marks the resulting IP as being owned by the chroot environment rooted at
    /tmp/tmp.Ax43B014m - meaning env_destroy_all.sh will destroy it without
    asking questions, as it makes no attempt to figure out if a chroot is in
    use at the moment.  However, in the future, it may be updated to check if
    a chroot is in use - and if so, it will avoid destroying this IP's 'lease'
    if the chroot is in use.
  $(basename "$0") --owner=lxc:dns-02
    Marks the resulting IP as being owned by the LXC container named 'dns-02'.
    env_destroy_all.sh should only destroy this IP if and only if it would also
    destroy that container.
The value for --owner is minimally a unique identifier.
EOF

add_flag subnet --default='192.168.122.0/24' "The IP range we can assign into."
add_usage_note <<EOF
Example of --subnet:
  $(basename "$0") --subnet=192.168.122.0/24
    This allows IPs in the range of 192.168.122.2 to 192.168.122.254 to be
    assigned.  The first IP in the subnet is assumed to be the gateway, and is
    reserved.  The broadcast IP is similarly reserved, explaining why the
    highest IP this setting would yield is 192.168.122.254.
  $(basename "$0") --subnet=10.0.0.0/16
    This allows IPs in the range of 10.0.0.2 to 10.0.255.254 to be used.
    TODO: Check that upper end is not 10.0.254.254.
EOF

add_flag lease_file --default=/tmp/ip.gigayak.allocations \
  "Where the IP lease information should be stored."

add_flag --boolean read_only "Does not generate a new lease when set."
parse_flags "$@"

# Check to make sure the owner specification is valid.
owner_type="$(echo "$F_owner" | sed -nre 's@^([^:]+):.*$@\1@gp')"
if [[ -z "$owner_type" ]]
then
  log_rote "failed to parse owner type from '$F_owner'"
  exit 1
fi
case "$owner_type" in
lxc)
  ;;
chroot)
  ;;
vm)
  ;;
*)
  log_rote "unknown owner type '$owner_type'"
  exit 1
esac

# Check to make sure we don't already have a lease.  We should never hand out
# multiple leases for the same owner.
if grep -E "^\S+\s+$(grep_escape "$F_owner")$" "$F_lease_file" >/dev/null 2>&1
then
  ip="$(grep -E "^\S+\s+$(grep_escape "$F_owner")$" "$F_lease_file" \
    | cut -d' ' -f1)"
  log_rote "found existing lease at $ip for '$F_owner'"
  echo "$ip"
  exit 0
fi

# Bail out if only reading leases.
if (( "$F_read_only" ))
then
  log_rote "in read-only mode, did not find IP for '$F_owner'"
  exit 1
fi

# Parse subnet specification formatting.
subnet_start="$(echo "$F_subnet" \
  | sed -nre 's@^([1-9][0-9]*\.[0-9]+\.[0-9]+\.[0-9]+)/[1-9][0-9]*$@\1@gp')"
if [[ -z "$subnet_start" ]]
then
  log_rote "failed to parse subnet start from '$F_subnet'"
  exit 1
fi
subnet_size="$(echo "$F_subnet" \
  | sed -nre 's@^[1-9][0-9]*\.[0-9]+\.[0-9]+\.[0-9]+/([1-9][0-9]*)$@\1@gp')"
if [[ -z "$subnet_size" ]]
then
  log_rote "failed to parse subnet size from '$F_subnet'"
  exit 1
fi

ip_to_dec()
{
  _ip="$1"
  if [[ -z "$_ip" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <ip>" >&2
    return 1
  fi
  _ipa="$(echo "$_ip" \
    | sed -nre 's@^([1-9][0-9]*)\.[0-9]+\.[0-9]+\.[0-9]+$@\1@gp')"
  if [[ -z "$_ipa" ]]
  then
    log_rote "failed to parse byte 1 of IP '$_ip'"
    return 1
  fi
  _ipb="$(echo "$_ip" \
    | sed -nre 's@^[1-9][0-9]*\.([0-9]+)\.[0-9]+\.[0-9]+$@\1@gp')"
  if [[ -z "$_ipb" ]]
  then
    log_rote "failed to parse byte 2 of IP '$_ip'"
    return 1
  fi
  _ipc="$(echo "$_ip" \
    | sed -nre 's@^[1-9][0-9]*\.[0-9]+\.([0-9]+)\.[0-9]+$@\1@gp')"
  if [[ -z "$_ipc" ]]
  then
    log_rote "failed to parse byte 3 of IP '$_ip'"
    return 1
  fi
  _ipd="$(echo "$_ip" \
    | sed -nre 's@^[1-9][0-9]*\.[0-9]+\.[0-9]+\.([0-9]+)$@\1@gp')"
  if [[ -z "$_ipd" ]]
  then
    log_rote "failed to parse byte 4 of IP '$_ip'"
    return 1
  fi
  dec="$(echo "$_ipa*2^24 + $_ipb*2^16 + $_ipc*2^8 + $_ipd*2^0" | bc)"
  if [[ -z "$dec" ]] || (( ! "$dec" ))
  then
    log_rote "failed to convert IP '$_ip' to decimal"
    return 1
  fi
  echo "$dec"
}

dec_to_ip()
{
  _dec="$1"
  if [[ -z "$_dec" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <ip in decimal form>" >&2
    return 1
  fi
  _ipa="$(echo "$_dec / 2^24" | bc)"
  if [[ -z "$_ipa" ]]
  then
    log_rote "failed to convert byte 1 of IP '$_dec'"
    return 1
  fi
  _ipb="$(echo "$_dec / 2^16 % 256" | bc)"
  if [[ -z "$_ipb" ]]
  then
    log_rote "failed to convert byte 2 of IP '$_dec'"
    return 1
  fi
  _ipc="$(echo "$_dec / 2^8 % 256" | bc)"
  if [[ -z "$_ipc" ]]
  then
    log_rote "failed to convert byte 3 of IP '$_dec'"
    return 1
  fi
  _ipd="$(echo "$_dec / 2^0 % 256" | bc)"
  if [[ -z "$_ipd" ]]
  then
    log_rote "failed to convert byte 4 of IP '$_dec'"
    return 1
  fi
  echo "$_ipa.$_ipb.$_ipc.$_ipd"
}

# Determine range of valid IPs we can choose from.
subnet_start_dec="$(ip_to_dec "$subnet_start")"
# Advance by 2 reserved IPs: first IP is reserved as network identifier, second
# is reserved by us for a default gateway.
valid_start_dec="$(echo "$subnet_start_dec + 2" | bc)"
valid_start="$(dec_to_ip "$valid_start_dec")"
# -1 here is because the size includes the IP at subnet_start
subnet_end_dec="$(echo "$subnet_start_dec + 2^(32-$subnet_size) - 1" | bc)"
# Retreat by 1 reserved IP: last IP is reserved as broadcast address.
valid_end_dec="$(echo "$subnet_end_dec - 1" | bc)"
valid_end="$(dec_to_ip "$valid_end_dec")"
log_rote "will choose IP between $valid_start and $valid_end"

# TODO: Validate that we've chosen a valid start point for the subnet, as they
# are bit-aligned based on the mask.

# Now we have a problem: how do we choose a random IP, while avoiding any
# collisions?  Perhaps just do random retry when we encounter a collision for
# now?
random_ip_dec()
{
  _start="$1"
  _end="$2"
  if [[ -z "$_start" || -z "$_end" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <start IP in decimal> <end IP in decimal>" >&2
    return 1
  fi
  echo "$_start + ($RANDOM*32768 + $RANDOM) % ($_end - $_start)" | bc
}
while true
do
  ip_dec="$(random_ip_dec "$valid_start_dec" "$valid_end_dec")"
  ip="$(dec_to_ip "$ip_dec")"
  log_rote "considering IP $ip"
  match="$(grep -E "^$(grep_escape "$ip")\s+" "$F_lease_file" || true)"
  if [[ -z "$match" ]]
  then
    log_rote "settling on IP $ip"
    break
  else
    log_rote "found collision: $match"
  fi
done

# Commit lease
echo "$ip $F_owner" >> "$F_lease_file"
echo "$ip"

# HACK SCALE: MAJOR
#
# This is all hard-coded shenanigans to keep dnsmasq up to date, by treating the
# 'lxc' owner namespace specially.  When an LXC-based owner is specified, we
# automatically update dnsmasq to contain the new IP - as if we were actually
# providing a DHCP lease.  This has a side effect of making dnsmasq 'see' new
# static leases for new containers.
if [[ "$owner_type" != "lxc" ]]
then
  exit 0
fi

host="$(echo "$F_owner" | sed -nre 's@^[^:]+:(.*)$@\1@gp')"
if [[ -z "$host" ]]
then
  log_rote "unable to parse hostname from owner '$F_owner'"
  exit 1
fi
log_rote "doing a super hacky DNS update to register '$host'"
# We'll take care to also remove the replica numbers from the host name, so that
# we get some DNS load balancing if we're lucky.
shared_host="$(echo "$host" | sed -nre 's@^([a-zA-Z0-9_-]+)-[0-9]+$@\1@gp')"
localstorage="$("$(DIR)/find_localstorage.sh")"
domain="$(get_config DOMAIN)"
echo "$ip $host $host.$domain $shared_host $shared_host.$domain" \
  >> "$localstorage/dns/dns/hosts.autogen"
# HACK: Some of my code relies on git.$domain and should be ashamed.
if [[ "$shared_host" == "gitzebo" ]]
then
  echo "$ip git git.$domain" >> "$localstorage/dns/dns/hosts.autogen"
fi
"$(DIR)/reload_dnsmasq.sh"
