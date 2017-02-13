#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"/*-*/
make install DESTDIR="/tools/$YAK_TARGET_ARCH"
