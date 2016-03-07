#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
cd "$YAK_WORKSPACE"/*-*/

make ARCH=i386 INSTALL_HDR_PATH=/tools/i686 headers_install
