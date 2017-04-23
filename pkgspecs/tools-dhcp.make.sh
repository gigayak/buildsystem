#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=4.3.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.isc.org/isc/dhcp/$version/dhcp-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

# Some options automatically fail when cross compiling :(
cat > config.cache <<'EOF'
ac_cv_file__dev_random=yes
EOF

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --cache-file=config.cache

# And DHCP pulls in bind and builds it... but fails to configure cross
# compilation correctly.  We use a hack provided by this site to resolve it:
#   http://www.jonisdumb.com/2011/02/compiling-isc-dhcp-420-dd-wrt.html
cd bind/
tar -xf bind.tar.gz
cd ../
sed \
  -r \
  -e 's@\$\{CC\}(.*/gen\.c)@${BUILD_CC}\1@g' \
  -i bind/bind-*/lib/export/dns/Makefile.in
sed \
  -r \
  -e 's@\./configure @BUILD_CC=gcc ./configure --host='"$CLFS_TARGET"' --build='"$CLFS_HOST"' --with-randomdev=/dev/random @g' \
  -i bind/Makefile

make
