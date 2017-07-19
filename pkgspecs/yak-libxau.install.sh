#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

cd *-*/
make install
