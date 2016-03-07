#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=4.2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="http://pkg-shadow.alioth.debian.org/releases/shadow-$version.tar.xz"
wget "$url"

tar -Jxf "shadow-$version.tar.xz"
cd shadow-*/

# Per the CLFS book:
#   The following sed command will disable the installation of the groups and
#   nologin programs, as better versions of these programs are provided by
#   other packages, and prevent Shadow from setting the suid bit on its
#   installed programs:
cp -v src/Makefile.in{,.orig}
sed \
  -e 's/groups$(EXEEXT) //' \
  -e 's/= nologin$(EXEEXT)/= /' \
  -e 's/\(^suidu*bins = \).*/\1/' \
  src/Makefile.in.orig > src/Makefile.in

# The CLFS book failed to also excise the man pages from Shadow for the groups
# and nologin programs, which causes packaging conflicts...
cp -v man/Makefile.in{,.orig}
sed -r \
  -e 's@(\s+)\S*groups\.\S*(\s+)@\1\2@g' \
  -e 's@(\s+)\S*nologin\.\S*(\s+)@\1\2@g' \
  man/Makefile.in.orig > man/Makefile.in

./configure \
  --prefix=/usr \
  --sysconfdir=/etc

make
