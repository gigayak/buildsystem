#!/bin/bash
set -Eeo pipefail

version=1.9.2
echo "$version" > /root/version
cd /root/
# TODO: Should have mirror selection logic here...  distributing this
# build script would not be very nice, as this is the primary source of
# truth for Apache mirrors.
wget "http://www.us.apache.org/dist/subversion/subversion-$version.tar.gz"
tar -zxf *.tar.gz
cd *-*/

./configure \
  --prefix=/usr \
  --with-serf=/usr
make
