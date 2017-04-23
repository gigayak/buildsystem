#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
cd "$YAK_WORKSPACE"/*-*/
make install

# TODO: CLFS book instructs you to symlink /usr/bin/perl to
#   /tools/ARCH/bin/perl here.  If absolutely needed, this should be
#   in an tools3-perl-aliases package.
