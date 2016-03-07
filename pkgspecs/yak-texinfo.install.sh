#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   If TeX will be used, install the components belonging in a TeX installation
make TEXMF=/usr/share/texmf install-tex
