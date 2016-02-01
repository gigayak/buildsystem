#!/bin/bash
set -Eeo pipefail

version=0.0.26
echo "$version" > /root/version
cd /root
wget "https://fedorahosted.org/releases/x/m/xmlto/xmlto-$version.tar.gz"
tar -zxf *.tar.gz
cd *-*/

./configure \
  --prefix=/usr
make
