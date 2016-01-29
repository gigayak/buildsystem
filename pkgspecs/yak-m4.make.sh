#!/bin/bash
set -Eeo pipefail

version=1.4.17
echo "$version" > /root/version
cd /root
wget "http://ftp.gnu.org/gnu/m4/m4-$version.tar.gz"
tar -zxf *.tar.gz
cd */

./configure --prefix=/usr
make
