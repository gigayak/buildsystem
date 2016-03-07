#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"/*-*/
#make DESTDIR=$CLFS/tools/i686 install
make DESTDIR=$CLFS install
