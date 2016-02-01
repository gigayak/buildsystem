#!/bin/bash
set -Eeo pipefail

cd /root
version=1.5.3
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/dejagnu/dejagnu-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/
./configure --prefix=/tools/i686
