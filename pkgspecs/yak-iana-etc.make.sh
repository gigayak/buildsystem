#!/bin/bash
set -Eeo pipefail

version=2.30
echo "$version" > /root/version
cd /root
wget "http://sethwklein.net/iana-etc-$version.tar.bz2"
tar -jxf *.tar.*
cd */

make
