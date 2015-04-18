#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root/*-*/
make install DESTDIR=/tools/i686
