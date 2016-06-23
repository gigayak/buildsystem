#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="1.3"
echo "$version" > version
url="https://github.com/tianon/cgroupfs-mount/archive/${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
