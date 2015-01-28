#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd "/root/linux-$version"
make ARCH=i386 INSTALL_HDR_PATH=/cross-tools/i686 headers_install
