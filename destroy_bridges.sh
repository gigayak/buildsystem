#!/bin/bash
set -Eeo pipefail

while read -r bridge
do
  ip link set dev "$bridge" down
  brctl delbr "$bridge"
done < <(brctl show | tail -n+2 | awk '{print $1}')
