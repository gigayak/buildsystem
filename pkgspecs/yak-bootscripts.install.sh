#!/bin/bash
set -Eeo pipefail
cd /root/bootscripts-cross-lfs-*/
make install-bootscripts
make install-network
make install-service-dhcpcd
