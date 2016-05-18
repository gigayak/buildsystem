#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/log.sh"

# HACK SCALE: MAJOR
#
# Existence of this file is indicative of a major hack.
#
# This allows us to poke at the hosts.autogen file and reload dnsmasq to
# manipulate DNS entries.  It ONLY works on the host running dnsmasq, and as a
# result, forces us to have a SPOF around DNS.  In the long run, we really
# need to have an RPC interface to the DNS stuff with some sort of consensus
# algorithm determining who owns which IP.

while read -r pid
do
  lxc_name="$(grep /lxc/ "/proc/$pid/cgroup" \
    | cut -d':' -f3 \
    | sort \
    | uniq \
    || true)"
  # Ignore non-LXC'ed dnsmasq instances.
  if [[ -z "$lxc_name" ]]
  then
    log_rote "ignoring non-LXC'ed dnsmasq /w PID $pid"
    continue
  fi

  # Ignore LXC instances not named "dns-##".
  if [[ -z "$(echo "$lxc_name" | sed -nre 's@^/lxc/dns-([0-9-]+)$@\1@gp')" ]]
  then
    log_rote "ignoring dnsmasq /w PID $pid and name $lxc_name"
    continue
  fi

  # Send a signal to trigger a reload of configuration.
  log_rote "telling dnsmasq /w PID $pid to reload config"
  kill -SIGHUP "$pid"
done < <(pgrep dnsmasq)

