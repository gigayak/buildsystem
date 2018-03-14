#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE/gcc-build"
make install-gcc
