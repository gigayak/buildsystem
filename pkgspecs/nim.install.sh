#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/nim
./koch install "/usr/bin"
mkdir -pv "/usr/lib"
cp -r lib "/usr/lib/nim"
cp koch "/usr/bin/koch"
