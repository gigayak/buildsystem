#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root/zlib-*/
make install
