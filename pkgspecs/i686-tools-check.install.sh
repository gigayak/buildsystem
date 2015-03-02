#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/check-*/
make install
