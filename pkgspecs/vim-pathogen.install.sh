#!/bin/bash
set -Eeo pipefail
version="$(cat /root/version)"

cd "/root/vim-pathogen-$version"
cd autoload
cp -v *.vim /usr/share/vim/vimfiles/plugin/
