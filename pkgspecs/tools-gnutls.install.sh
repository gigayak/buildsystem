#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"/*-*/
make install

# See make.sh for the dirty details on this line.
rm -rf "/tools/${YAK_TARGET_ARCH}/share/info"

# make install should really create all necessary config directories.
# But... it doesn't.
mkdir -pv "/tools/$YAK_TARGET_ARCH/etc/ssl/certs"
