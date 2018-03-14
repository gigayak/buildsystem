#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE/binutils-build"
make install
