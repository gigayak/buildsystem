#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=1.6.0
echo "$version" > version
urldir="http://www.netfilter.org/projects/iptables/files"
url="${urldir}/iptables-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
