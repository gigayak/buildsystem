#!/bin/bash
set -Eeo pipefail

cd /root
version=1.0.6
echo "$version" > /root/version
url="http://www.bzip.org/$version/bzip2-$version.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/

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

