#!/bin/bash
set -Eeo pipefail

cd /root
version=2.47.4
major="$(echo "$version" | sed -re 's@\.[0-9]+$@@')"
echo "$version" > /root/version
urldir="http://ftp.gnome.org/pub/gnome/sources/glib/$major"
url="$urldir/glib-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr
make
