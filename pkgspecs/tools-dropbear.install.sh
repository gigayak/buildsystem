#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"/dropbear-*/
make install
