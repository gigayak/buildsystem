#!/bin/bash
set -Eeo pipefail
version="$(cat /root/version)"

cd /root
cp -r vim-go-$version/ /usr/share/vim/vimfiles/bundle/vim-go
