#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd "$YAK_WORKSPACE"/gcc-build
make install

# Per CLFS: "Install the libiberty header file that is needed by some packages"
# TODO: Why isn't this installed by make install?
cp -v ../gcc-4*/include/libiberty.h /tools/i686/include/
