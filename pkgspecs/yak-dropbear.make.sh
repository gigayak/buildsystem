#!/bin/bash
set -Eeo pipefail

cd /root
version=2015.67
echo "$version" > /root/version
url="https://matt.ucc.asn.au/dropbear/releases/dropbear-$version.tar.bz2"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/

./configure \
  --prefix=/usr
make
