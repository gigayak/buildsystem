#!/bin/bash
set -Eeo pipefail
set -x

version=4.0.5
echo "$version" > "$YAK_WORKSPACE/version"
wget http://download.zeromq.org/zeromq-$version.tar.gz
tar -zxf zeromq-$version.tar.gz
cd zeromq-$version

./configure --prefix=/usr
make
