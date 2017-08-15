#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
url="https://github.com/nim-lang/c2nim/archive/master.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
mkdir -pv ~/.config/nimble
grep -E '^version' c2nim.nimble | awk '{print $3}' | tr -d '"' > ../version
nimble build
nimble install # because for some reason, it installs to /.nimble/bin...
