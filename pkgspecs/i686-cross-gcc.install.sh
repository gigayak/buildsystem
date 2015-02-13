#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
cd /root/gcc-build
make install
