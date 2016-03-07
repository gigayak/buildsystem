#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=7.4
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.vim.org/pub/vim/unix/vim-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*

cd vim*/
./configure \
  --prefix=/usr
make
