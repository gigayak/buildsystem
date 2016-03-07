#!/bin/bash
set -Eeo pipefail

version=2.4.0
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"
wget "http://prdownloads.sourceforge.net/scons/scons-$version.tar.gz"
tar -xf *.tar.*
