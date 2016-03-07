#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"/*-*/
make install DESTDIR=/tools/i686
