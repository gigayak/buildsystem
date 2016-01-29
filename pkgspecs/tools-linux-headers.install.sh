#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

version="$(</root/version)"
cd "/root/linux-$version"
make ARCH=i386 INSTALL_HDR_PATH=/tools/i686 headers_install
