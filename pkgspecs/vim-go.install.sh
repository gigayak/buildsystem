#!/bin/bash
set -Eeo pipefail
version="$(cat "$YAK_WORKSPACE/version")"

cd "$YAK_WORKSPACE"
cp -r vim-go-$version/ /usr/share/vim/vimfiles/bundle/vim-go
