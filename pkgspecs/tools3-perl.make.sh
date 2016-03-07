#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="5.22.0"
echo "$version" > "$YAK_WORKSPACE/version"
major_version="$(echo "$version" | sed -nre 's@^([0-9]+)\..*$@\1@gp').0"
url="http://www.cpan.org/src/$major_version/perl-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/
# Per the CLFS book:
#   Change a hardcoded path from /usr/include to /tools/.../include
sed -i 's@/usr/include@/tools/i686/include@g' ext/Errno/Errno_pm.PL

./configure.gnu \
  --prefix=/tools/i686 \
  -Dcc="gcc"

make
