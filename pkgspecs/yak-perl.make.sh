#!/bin/bash
set -Eeo pipefail

cd /root
version="5.22.0"
echo "$version" > /root/version
major_version="$(echo "$version" | sed -nre 's@^([0-9]+)\..*$@\1@gp').0"
url="http://www.cpan.org/src/$major_version/perl-$version.tar.gz"
wget "$url"
tar -zxf *.tar.*

# Per CLFS book:
#   By default, Perl's Compress::Raw::Zlib and Compress::Raw::Bzip2 modules build and
#   link against internal copies of Zlib and Bzip2. The following command will make
#   Perl use the system-installed copies of these libraries:
export BUILD_ZLIB=False
export BUILD_BZIP2=0

cd *-*/
./configure.gnu \
  --prefix=/usr \
  -Dvendorprefix=/usr \
  -Dman1dir=/usr/share/man/man1 \
  -Dman3dir=/usr/share/man/man3 \
  -Dpager="/bin/less -isR" \
  -Dusethreads \
  -Duseshrplib
make