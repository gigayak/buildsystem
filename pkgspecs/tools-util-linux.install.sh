#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/util-linux-*/
make install
