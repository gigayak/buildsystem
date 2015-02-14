#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/binutils-build
make install
