#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
cd "$YAK_WORKSPACE"/bootscripts-cross-lfs-*/
make install-bootscripts
make install-network
make install-service-dhcpcd
