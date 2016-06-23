#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="9.10.4-P1"
echo "$version" > version
urlversion="$(echo "$version" | tr '.' '-' | tr '[:upper:]' '[:lower:]')"
url="https://www.isc.org/downloads/file/bind-${urlversion}/?version=tar-gz"
wget -O bind.tar.gz "$url"
tar -xf bind.tar.gz
cd *-*/
./configure --prefix=/usr
make
