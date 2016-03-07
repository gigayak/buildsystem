#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=6.9.4
echo "$version" > "$YAK_WORKSPACE/version"
url="http://roy.marples.name/downloads/dhcpcd/dhcpcd-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --sbindir=/sbin \
  --sysconfdir=/etc \
  --dbdir=/var/lib/dhcpcd \
  --libexecdir=/usr/lib/dhcpcd
make
