#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"/*-*/
make DESTDIR=$CLFS install
