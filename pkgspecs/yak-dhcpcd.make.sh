#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/download.sh"

cd "$YAK_WORKSPACE"
version=6.9.4
echo "$version" > "$YAK_WORKSPACE/version"
urls=()
file="dhcpcd-${version}.tar.xz"
# Main site.
urls+=("http://roy.marples.name/downloads/dhcpcd/$file")
# And mirrors, in case the main site is down.
urls+=("http://ftp.oregonstate.edu/.1/blfs/conglomeration/dhcpcd/$file")
urls+=("http://ftp.lfs-matrix.net/pub/blfs/conglomeration/dhcpcd/$file")
download_one_of "${urls[@]}"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --sbindir=/sbin \
  --sysconfdir=/etc \
  --dbdir=/var/lib/dhcpcd \
  --libexecdir=/usr/lib/dhcpcd
make
