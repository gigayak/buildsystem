#!/bin/bash
set -Eeo pipefail

version=7.10
echo "$version" > /root/version
cd /root
wget "http://ftp.gnu.org/gnu/gdb/gdb-$version.tar.gz"
tar -xf *.tar.*
cd */

# tools2-texinfo will be pointing at the original build host's
# perl binary at /usr/bin/perl.  This hopefully points it at the
# tools3-perl package's binary, instead.
# TODO: Make tools3-texinfo play nice here?
export PERL=/tools/i686/bin/perl
./configure --prefix=/tools/i686
make
