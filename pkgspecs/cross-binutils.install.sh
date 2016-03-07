#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
cd "$YAK_WORKSPACE"/binutils-build
make install
