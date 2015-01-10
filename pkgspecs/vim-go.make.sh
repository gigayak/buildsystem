#!/bin/bash
set -Eeo pipefail

version=1.0
echo "$version" > /root/version

url="https://github.com/fatih/vim-go/archive/v$version.tar.gz"
cd /root
wget "$url"
tar -zxf "v$version.tar.gz"
