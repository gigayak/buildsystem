#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=3.7.2
echo "$version" > "$YAK_WORKSPACE/version"
#url="https://github.com/balabit/syslog-ng/archive/syslog-ng-${version}.tar.gz"
urldir="https://github.com/balabit/syslog-ng/releases/download"
url="${urldir}/syslog-ng-${version}/syslog-ng-${version}.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
#./autogen.sh
./configure \
  --prefix=/usr
make
