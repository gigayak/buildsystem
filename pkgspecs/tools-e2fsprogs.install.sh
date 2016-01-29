#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/build
make install
make install-libs
