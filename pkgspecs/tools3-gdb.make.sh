#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

version=7.10
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"
wget "http://ftp.gnu.org/gnu/gdb/gdb-$version.tar.gz"
tar -xf *.tar.*
cd *-*/

# tools2-texinfo will be pointing at the original build host's
# perl binary at /usr/bin/perl.  This hopefully points it at the
# tools3-perl package's binary, instead.
# TODO: Make tools3-texinfo play nice here?
export PERL="/tools/${YAK_TARGET_ARCH}/bin/perl"
./configure --prefix="/tools/${YAK_TARGET_ARCH}"
make
