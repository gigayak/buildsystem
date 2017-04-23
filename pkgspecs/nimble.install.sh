#!/bin/bash
set -Eeo pipefail
mkdir -pv "$HOME/.nimble"
wget \
  -O "$HOME/.nimble/packages_official.json" \
  "https://raw.githubusercontent.com/nim-lang/packages/master/packages.json"
cd "$YAK_WORKSPACE"/*-*/
cp src/nimble /usr/bin/
# Who knows why nimble expects nimblepkg in /usr/bin/...  not me.
cp -r src/nimblepkg /usr/bin/nimblepkg
