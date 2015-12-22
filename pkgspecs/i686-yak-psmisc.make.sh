#!/bin/bash
set -Eeo pipefail

cd /root
version=22.21
echo "$version" > /root/version
url="https://gitlab.com/psmisc/psmisc/repository/archive.tar.gz?ref=v$version"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
./autogen.sh \
  --prefix=/usr
make
