#!/bin/bash
set -Eeo pipefail

version=1.3.8
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"
wget "https://archive.apache.org/dist/serf/serf-$version.tar.bz2"
tar -xf *.tar.*
cd *-*/
scons \
  PREFIX=/usr
#  APR= \
#  APU= \
#  OPENSSL= \
