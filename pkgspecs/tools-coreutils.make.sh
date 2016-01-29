#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=8.23
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/coreutils/coreutils-$version.tar.xz"
wget "$url"

tar -Jxf "coreutils-$version.tar.xz"
cd coreutils-*/

# Manually set which mechanisms to use to build df, which is needed for a
# healthy system.  ./configure fails at figuring these out when cross compiling.
cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_working_mkstemp=yes
EOF

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --enable-install-program=hostname \
  --cache-file=config.cache

make
