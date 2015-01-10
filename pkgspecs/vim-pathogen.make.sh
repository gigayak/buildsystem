#!/bin/bash
set -Eeo pipefail

version=2.3
echo "$version" > /root/version

url="https://github.com/tpope/vim-pathogen/archive/v$version.tar.gz"
cd /root
wget "$url"
tar -zxf "v$version.tar.gz"
