#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDSYSTEM/escape.sh"
cd "$YAK_WORKSPACE"
version="2.2.31"
echo "$version" > version
filename="httpd-${version}.tar.gz"
filename_escaped="$(sed_escape "$filename")"
url="$(wget -O- -q \
    "https://www.apache.org/dyn/closer.cgi?path=httpd/$filename" \
  | sed -nre 's@.*<a\shref="([^"]+'"$filename_escaped"')".*$@\1@gp' \
  | head -n 1)"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr
make
