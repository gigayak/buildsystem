#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
cd "$YAK_WORKSPACE"/*-*/

# TODO: ARCH=i386 originally - does using fully-specified ARCH cause problems?
make \
  ARCH="$YAK_TARGET_ARCH" \
  INSTALL_HDR_PATH="/tools/$YAK_TARGET_ARCH" \
  headers_install
