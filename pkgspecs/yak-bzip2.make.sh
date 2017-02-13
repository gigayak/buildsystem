#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=1.0.6
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.bzip.org/$version/bzip2-$version.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

# /lib/ -> /lib64/ translation for 64-bit platforms.
cp -v Makefile{,.orig}
sed -r \
  -e 's@/lib([|/ ]|$)@/'"$lib"'\1@g' \
  -i Makefile

# Per CLFS book:
#   By default Bzip2 creates some symlinks that use absolute pathnames. The
#   following sed will cause them to be created with relative paths
#   instead:
sed -i -e 's:ln -s -f $(PREFIX)/bin/:ln -s :' Makefile
# Per CLFS book:
#   Make Bzip2 install its manpages in /usr/share/man instead of /usr/man:
sed -i 's@X)/man@X)/share/man@g' ./Makefile

make -f Makefile-libbz2_so
make clean
make

