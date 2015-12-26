#!/bin/bash
set -Eeo pipefail

cd /root
version=7.4
echo "$version" > /root/version
url="http://ftp.vim.org/pub/vim/unix/vim-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*

cd vim*/
./configure \
  --prefix=/usr
make
