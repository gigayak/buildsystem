#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
cd icu/source/
make install
