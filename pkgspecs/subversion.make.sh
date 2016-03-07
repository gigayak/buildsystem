#!/bin/bash
set -Eeo pipefail

version=1.9.3
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"/
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
