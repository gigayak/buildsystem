#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# HACK SCALE: MAJOR
#
# Since we don't have the ability to query our DNS servers nicely while
# bootstrapping, we just read the hosts file directly and hope for the best.

# This script generates an /etc/resolv.conf and puts it on standard output.

cat <<EOF
; These options force us to choose a DNS replica at random, and to fail over
; after a single attempt fails to return within one second.
options timeout:1 attempts:1 rotate
EOF

found_servers=0

# HACK SCALE: MAJOR
#
# When in lfs.stage3.sh, we have no access to ping, nslookup, or anything of
# the sort.  However, we're pretty much guaranteed that /etc/resolv.conf has
# the correct nameservers populated, as we will not have a local repo cache.
if [[ -e "/tools" ]]
then
  echo "$(basename "$0"): using /etc/resolv.conf instead of generating it" >&2
  cat /etc/resolv.conf
  exit 0
fi

# HACK SCALE: MINOR
#
# We don't really know how many DNS servers to expect, and we can't just poll
# a single dns.jgilik.com record (yet).  So... we hard code the DNS server IDs.
for i in 01 02
do
  # Ignore nonexistent containers.
  if ! lxc-info --name="dns-$i" >/dev/null 2>&1
  then
    continue
  fi
  ip="$("$(DIR)/create_ip.sh" --read_only --owner="lxc:dns-$i" || true)"
  if [[ -z "$ip" ]]
  then
    continue
  fi
  echo "; IP for dns-$i"
  echo "nameserver $ip"
  found_servers="$(expr "$found_servers" + 1)"
done

if (( "$found_servers" == 0 ))
then
  echo "; public DNS IP (could not find internal DNS)"
  echo "nameserver 8.8.8.8"
fi
