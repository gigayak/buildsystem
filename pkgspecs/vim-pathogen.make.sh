#!/bin/bash
set -Eeo pipefail

version=2.3
echo "$version" > "$YAK_WORKSPACE/version"

url="https://github.com/tpope/vim-pathogen/archive/v$version.tar.gz"
cd "$YAK_WORKSPACE"
wget "$url"
tar -zxf "v$version.tar.gz"
