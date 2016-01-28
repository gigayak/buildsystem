#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/mkroot.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"

add_usage_note <<EOF
This utility should create all network interfaces in a reasonably sane way.

It sets up:
- bridge network
- NAT from bridge to external network
- port forwarding for proxy-01

It does not survive reboots at the moment, though pieces do.  This means it's
a bit of a nightmare to redo upon reboot still...

WARNING: It assumes eth1 is connected to the internet.  This is not standard.
TODO: Default to eth0, allow it to be configured.
EOF
parse_flags "$@"

# Ensure a network bridge exists and is up.
# CentOS-specific implementation.
create_centos_bridge()
{
  local _bridge_name="$1"
  local _ip="$2"
  local _netmask="$3"
  if [[ -z "$_bridge_name" || -z "$_ip" || -z "$_netmask" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <bridge name> <ip> <netmask>" >&2
    return 1
  fi

  if ip link show "$_bridge_name" >/dev/null 2>&1
  then
    echo "${FUNCNAME[0]}: bridge $(sq "$_bridge_name") already exists" >&2
    return 0
  else
    echo "${FUNCNAME[0]}: creating bridge $(sq "$_bridge_name")" >&2
    # TODO: can this be done in a non-persistent way?
    cat >> "/etc/sysconfig/network-scripts/ifcfg-$_bridge_name" <<EOF
DEVICE="$_bridge_name"
TYPE="Bridge"
BOOTPROTO="static"
IPADDR="$_ip"
NETMASK="$_netmask"
EOF
  fi
  # Ensure bridge up.
  if (( ! "$(<"/sys/class/net/$_bridge_name/carrier")" ))
  then
    echo "${FUNCNAME[0]}: bringing bridge $(sq "$_bridge_name") up" >&2
    ifup "$_bridge_name"
  else
    echo "${FUNCNAME[0]}: bridge $(sq "$_bridge_name") already up" >&2
  fi
}

# Ensure a network bridge exists and is up.
# Ubuntu-specific implementation.
create_ubuntu_bridge()
{
  local _bridge_name="$1"
  local _ip="$2"
  local _netmask="$3"
  if [[ -z "$_bridge_name" || -z "$_ip" || -z "$_netmask" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <bridge name> <ip> <netmask>" >&2
    return 1
  fi

  # Ensure bridge exists.
  # Following along with these links:
  #   https://help.ubuntu.com/community/NetworkConnectionBridge
  if ip link show "$_bridge_name" >/dev/null 2>&1
  then
    echo "${FUNCNAME[0]}: bridge $(sq "$_bridge_name") already exists" >&2
  else
    echo "${FUNCNAME[0]}: creating bridge $(sq "$_bridge_name")" >&2
    brctl addbr "$_bridge_name"
    local _prefix_len="$(netmask_to_prefix_length "$_netmask")"
    ip address add "$_ip"/"$_prefix_len" dev "$_bridge_name"
  fi

  # Ensure bridge up.
  ip link set "$_bridge_name" up
}

netmask_to_prefix_length()
{
  local _prefix="$1"

  # Convert all bytes to binary
  local _bin=""
  local _byte
  while read -r _byte
  do
    _bin="${_bin}$(printf '%08d' "$(echo "obase=2;$_byte" | bc)")"
  done < <(echo "$@" | tr '.' '\n')

  # Count how many leading 1's exist to yield prefix length
  echo -n "$_bin" \
    | sed -nre 's@^(1*)([^1].*)?$@\1@gp' \
    | wc -c
}

bridge()
{
  local _bridge_name="$1"
  local _ip="$2"
  local _netmask="$3"
  if [[ -z "$_bridge_name" || -z "$_ip" || -z "$_netmask" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <bridge name> <ip> <netmask>" >&2
    return 1
  fi

  if which yum >/dev/null 2>&1
  then
    create_centos_bridge "$@"
  elif which apt-get >/dev/null 2>&1
  then
    create_ubuntu_bridge "$@"
  fi
}


echo "Setting nameserver to 8.8.8.8" >&2
echo "(Many consumer ISPs have unreliable nameservers.)" >&2
echo "nameserver 8.8.8.8" > /etc/resolv.conf

bridge virbr0 192.168.122.1 255.255.255.0
# TODO: Which interface to NAT to should be a configuration option....
ext_if=eth0 # Which external interface to NAT to
ext_ip="$(ip addr show primary dev "$ext_if" scope global \
  | sed -nre 's@^.*inet ([0-9.]+)\/.*$@\1@gp')"
proxy_ip=""
if [[ -e /tmp/ip.gigayak.allocations ]]
then
  proxy_ip="$(awk '/lxc:proxy-01/ {print $1}' /tmp/ip.gigayak.allocations)"
fi
make_temp_dir temp
rules="$temp/iptables.rules.nat"
cat > "$rules" <<EOF
*nat
:PREROUTING ACCEPT
:POSTROUTING ACCEPT
:OUTPUT ACCEPT
EOF

# This port forwarding attempt is commented as "does not work", but I recall
# it working at some point in time.
if [[ ! -z "$proxy_ip" ]] && false # do not do non-working stuff
then
  # port forwarding attempt - does not work
  echo "-A PREROUTING -p tcp -i $ext_if --dport 443 -m state" \
    "--state NEW,ESTABLISHED,RELATED -j DNAT --to $proxy_ip" \
    >> "$rules"
fi
echo "-A POSTROUTING -s 192.168.122.0/24 -o $ext_if -j SNAT --to-source $ext_ip" \
  >> "$rules"
echo "COMMIT" >> "$rules"

cat >> "$rules" <<EOF
*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -p icmp -j ACCEPT 
-A INPUT -i lo -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT 
-A INPUT -j REJECT --reject-with icmp-host-prohibited 
COMMIT
EOF

echo "$(basename "$0"): Generated these rules:" >&2
cat "$rules" >&2
echo >&2
echo "$(basename "$0"): Applying generated rules." >&2
iptables-restore < "$rules"
echo "$(basename "$0"): You should be all set." >&2
