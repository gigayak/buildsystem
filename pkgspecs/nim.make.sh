#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version="0.17.2"
echo "$version" > version
url="https://github.com/nim-lang/Nim/archive/v${version}.tar.gz"
wget -O nim.tar.gz "$url"

cs_url="https://github.com/nim-lang/csources/archive/v${version}.tar.gz"
wget -O csources.tar.gz "$cs_url"

for pkg in *.tar.*
do
  tar -xf "$pkg"
done
mv Nim-*/ nim
mv csources-*/ nim/csources

cd nim/csources
./build.sh

cd ..
nim="$PWD/bin/nim"
"$nim" c -d:release koch
./koch boot -d:release
