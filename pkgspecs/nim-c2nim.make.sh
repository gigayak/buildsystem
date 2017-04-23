#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
url="https://github.com/nim-lang/c2nim/archive/master.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
grep -E '^version' c2nim.nimble | awk '{print $3}' | tr -d '"' > ../version
nimble build
