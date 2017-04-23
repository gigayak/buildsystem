#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh
cd "$YAK_WORKSPACE"/gcc-build
make install

# Per CLFS: "Install the libiberty header file that is needed by some packages"
# TODO: Why isn't this installed by make install?
cp -v ../gcc-4*/include/libiberty.h "/tools/${YAK_TARGET_ARCH}/include/"
