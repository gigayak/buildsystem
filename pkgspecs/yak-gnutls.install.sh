#!/bin/bash
set -Eeo pipefail

version="$(<"$YAK_WORKSPACE/version")"
cd "$YAK_WORKSPACE/"*-*/
make install

# See make.sh for the dirty details on this line.
rm -rf /usr/share/info
