#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

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

# Per the CLFS book:
#   Tell Shadow to use passwd in /tools/ARCH/bin:
cat > config.cache <<EOF
shadow_cv_passwd_dir=/tools/${YAK_TARGET_ARCH}/bin
EOF

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --cache-file=config.cache \
  --enable-subordinate-ids=no

# Per the CLFS book:
#   Append to config.h since a test program will not be ran when
#   cross-compiling:
# Note: the CLFS book calls for ENABLE_SUBUIDS, while there's actually no U.
echo "#define ENABLE_SUBIDS 1" >> config.h

make
