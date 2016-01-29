#!/bin/bash
set -Eeo pipefail

cd /root
version=6.9.4
echo "$version" > /root/version
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
