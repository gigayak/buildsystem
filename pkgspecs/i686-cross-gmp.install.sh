#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
version="$(</root/version)"
cd /root/gmp-*/
make install
