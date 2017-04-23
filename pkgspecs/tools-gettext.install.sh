#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh
cd "$YAK_WORKSPACE"/gettext-*/

# Bit of a weird install - we just want ONE binary.
cd gettext-tools/
cp -v "src/msgfmt" "/tools/${YAK_TARGET_ARCH}/bin"
