#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=4.4
echo "$version" > "$YAK_WORKSPACE/version"
urldir="https://github.com/shadow-maint/shadow/releases/download/$version"
url="$urldir/shadow-${version}.tar.gz"
wget "$url"

tar -xf shadow-*.tar.*
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
