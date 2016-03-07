#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd "$YAK_WORKSPACE"/*-*/
make CROSS_COMPILE="${CLFS_TARGET}-" install
