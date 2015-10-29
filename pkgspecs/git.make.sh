#!/bin/bash
set -Eeo pipefail

version=2.6.1
echo "$version" > /root/version
cd /root
wget \
  "https://github.com/git/git/archive/v$version.tar.gz" \
  -O git.tar.gz
tar -zxf git.tar.gz
cd */

make prefix=/usr all
