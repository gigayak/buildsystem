#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

cd llvm-build
cmake --build . --target install
