#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
cd /root/cloog-*/
make install
