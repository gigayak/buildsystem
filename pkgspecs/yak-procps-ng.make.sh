#!/bin/bash
set -Eeo pipefail

version=3.3.11
url="https://gitlab.com/procps-ng/procps/repository/archive.tar.gz?ref=v$version"
cd /root
echo "$version" > version
wget --no-check-certificate "$url" -O "procps-ng-$version.tar.gz"
tar -zxf *.tar.gz
cd *-*/

# Since this is pulling from a Git tag - `configure` and `Makefile` will not
# exist.  `autogen.sh` will create them.
./autogen.sh
# --disable-kill prevents us from building and installing `kill`, which
# util-linux installed a better version of.
./configure \
  --prefix=/usr \
  --with-ncurses=/usr \
  --docdir="/usr/share/doc/procps-ng-$version" \
  --disable-kill
make
