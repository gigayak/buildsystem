#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
version="$(<"$YAK_WORKSPACE/version")"
cd "$YAK_WORKSPACE"/gmp-*/
make install
