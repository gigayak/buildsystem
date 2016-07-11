#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="7.2p2"
echo "$version" > version
urldir="http://ftp5.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable"
url="${urldir}/openssh-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
