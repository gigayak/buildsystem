#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.5.3
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/dejagnu/dejagnu-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/
./configure --prefix=/tools/i686
