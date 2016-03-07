#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/bootscripts-cross-lfs-*/
make install-bootscripts
make install-network
make install-service-dhcpcd
