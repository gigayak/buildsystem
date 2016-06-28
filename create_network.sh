#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/config.sh"
source "$(DIR)/mkroot.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
source "$(DIR)/net.sh"

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

# Ensure all kernel modules are in place.
# (A barebones system may not load these.)
#
# TODO: Perhaps factor stuff like this out, into a machine prep script?
# That way it's still easy to bootstrap, but informed admins can use Puppet
# or whatever to prep their machine.
module_dir="/lib/modules/$(uname -r)/kernel"
for module in \
  nf_nat \
  nf_nat_ipv4 \
  nf_nat_masquerade_ipv4 \
  iptable_nat \
  ipt_MASQUERADE \
  xt_nat
do
  if ! lsmod \
    | awk '{print $1}' \
    | tail -n+2 \
    | grep -E "^${module}\$" \
    >/dev/null 2>&1
  then
    log_rote "loading $(sq "$module") kernel module"
    insmod "$(find "$module_dir" -iname "${module}.ko")"
  fi
done

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
    log_rote "bridge $(sq "$_bridge_name") already exists"
    return 0
  else
    log_rote "creating bridge $(sq "$_bridge_name")"
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
    log_rote "bringing bridge $(sq "$_bridge_name") up"
    ifup "$_bridge_name"
  else
    log_rote "bridge $(sq "$_bridge_name") already up"
  fi
}

# Ensure a network bridge exists and is up.
create_brctl_bridge()
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
    log_rote "bridge $(sq "$_bridge_name") already exists"
  else
    log_rote "creating bridge $(sq "$_bridge_name")"
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

  distro="$("$(DIR)/os_info.sh" --distribution)"
  if [[ "$distro" == "centos" ]]
  then
    create_centos_bridge "$@"
  elif [[ "$distro" == "ubuntu" || "$distro" == "yak" ]]
  then
    create_brctl_bridge "$@"
  else
    log_fatal "no idea how to create bridge in $distro"
  fi
}


log_rote "setting nameserver to 8.8.8.8"
log_rote "(many consumer ISPs have unreliable nameservers.)"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

br_subnet="$(get_config CONTAINER_SUBNET)"
br_gateway_ip="$(parse_subnet_gateway "$br_subnet")"
br_subnet_size="$(parse_subnet_size "$br_subnet")"
br_mask="$(size_to_mask "$br_subnet_size")"
bridge virbr0 "$br_gateway_ip" "$br_mask"
# TODO: Which interface to NAT to should be a configuration option....
ext_if=eth0 # Which external interface to NAT to
ext_ip="$(ip addr show primary dev "$ext_if" scope global \
  | sed -nre 's@^.*inet ([0-9.]+)\/.*$@\1@gp')"
proxy_ip=""
if [[ -e /tmp/ip.gigayak.allocations ]]
then
  proxy_ip="$(awk '/lxc:proxy-01/ {print $1}' /tmp/ip.gigayak.allocations)"
fi

# enable iptables
echo 1 > /proc/sys/net/ipv4/ip_forward

# firewall configuration
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
echo "-A POSTROUTING -s $br_subnet -o $ext_if -j SNAT --to-source $ext_ip" \
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

log_rote "Generated these rules:"
cat "$rules" >&2
echo >&2
log_rote "Applying generated rules."
iptables-restore < "$rules"
log_rote "You should be all set."
