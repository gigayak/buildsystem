#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=2.3
echo "$version" > version
urldir="https://github.com/tmux/tmux/releases/download/$version"
url="$urldir/tmux-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd */
./configure --prefix=/usr
make
