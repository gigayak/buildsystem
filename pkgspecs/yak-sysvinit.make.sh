#!/bin/bash
set -Eeo pipefail

cd /root
version=2.88dsf
echo "$version" > /root/version
url="http://download.savannah.gnu.org/releases/sysvinit/sysvinit-$version.tar.bz2"
wget "$url"
tar -xf *.tar.*

cd *-*/
# Per CLFS book:
#   Apply a sed to disable several programs from being built and installed as better
#   versions are provided by other packages:
sed \
  -i \
  -e 's/\ sulogin[^ ]*//' \
  -e 's/pidof\.8//' \
  -e '/ln .*pidof/d' \
  -e '/utmpdump/d' \
  -e '/mountpoint/d' \
  -e '/mesg/d' \
  src/Makefile

make -C src clobber
make -C src
