#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root/*/
#make DESTDIR=$CLFS/tools/i686 install
make DESTDIR=$CLFS install
