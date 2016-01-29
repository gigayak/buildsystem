#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/patch-*/
make install
