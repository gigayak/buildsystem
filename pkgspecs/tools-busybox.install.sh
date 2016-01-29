#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/*-*/
make CROSS_COMPILE="${CLFS_TARGET}-" install
