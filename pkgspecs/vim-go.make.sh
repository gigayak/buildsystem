#!/bin/bash
set -Eeo pipefail

version=1.0
echo "$version" > "$YAK_WORKSPACE/version"

url="https://github.com/fatih/vim-go/archive/v$version.tar.gz"
cd "$YAK_WORKSPACE"
wget "$url"
tar -zxf "v$version.tar.gz"
