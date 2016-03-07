#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Some of the programs from Kbd are used by the CLFS Bootscripts to initialize the
#   system, so those binaries need to be on the root partition:
mv -v /usr/bin/{dumpkeys,kbd_mode,loadkeys,setfont} /bin

# Per CLFS book:
#   Install the documentation:
mkdir -v /usr/share/doc/kbd-$(<"$YAK_WORKSPACE/version")
cp -R -v docs/doc/* /usr/share/doc/kbd-$(<"$YAK_WORKSPACE/version")

