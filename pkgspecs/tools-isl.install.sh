#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd "$YAK_WORKSPACE"/isl-*/
make install
