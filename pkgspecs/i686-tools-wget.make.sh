#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=1.16.3
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/wget/wget-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

# --without-ssl removes HTTPS support, but with the benefit of not requiring us
# to attempt cross compilation of GNUTLS and Nettle before hand.
#
# TODO: We may want to use HTTPS for serving source packages in the future :(
./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}" \
  --without-ssl
make
