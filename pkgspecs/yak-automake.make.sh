#!/bin/bash
set -Eeo pipefail

# automake and autoconf are required by procps-ng, which is
# downloaded from a Git tag nowadays and does not have `configure`
# in the distribution archive as a result.  However, since the
# build process for these packages results in binaries that refer
# to `perl` statically, we wind up with references to `/tools` -
# so this package is tagged as tools3, and will be rebuilt after
# `yak-perl` is built.

version=1.15
echo "$version" > /root/version
cd /root
wget "http://ftp.gnu.org/gnu/automake/automake-$version.tar.gz"
tar -zxf *.tar.gz
cd */

./configure \
  --prefix=/usr
make
