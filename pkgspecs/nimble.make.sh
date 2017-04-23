#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=0.8.4
echo "$version" > version
url="https://github.com/nim-lang/nimble/archive/v${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
nim c src/nimble

