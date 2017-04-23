#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   If TeX will be used, install the components belonging in a TeX installation
make TEXMF=/usr/share/texmf install-tex
