#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Install the documentation:
mkdir -v /usr/share/doc/gawk-4.1.3
cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.3

