#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=3.9.1
echo "$version" > "$YAK_WORKSPACE/version"
urldir="https://github.com/balabit/syslog-ng/releases/download"
url="${urldir}/syslog-ng-${version}/syslog-ng-${version}.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
