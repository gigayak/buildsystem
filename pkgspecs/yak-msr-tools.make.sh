#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="1.3"
echo "$version" > version
urldir="https://01.org/sites/default/files/downloads/msr-tools"
url="$urldir/msr-tools-${version}.zip"
wget "$url"
unzip *.zip
cd *-*/
make
