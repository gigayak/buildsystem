#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="0.15.1b"
echo "$version" > version
url="ftp://ftp.mars.org/pub/mpeg/libmad-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */

./configure --prefix=/usr

# The latest version of libmad isn't compatible with GCC >= 4.3, as it uses
# -fforce-mem, which was removed per http://stackoverflow.com/a/16836044
sed -re 's@ -fforce-mem@@g' -i Makefile

make
