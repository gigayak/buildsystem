#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=4.4.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/findutils/findutils-$version.tar.gz"
wget "$url"

tar -zxf "findutils-$version.tar.gz"
cd findutils-*/

# Corrections for autoconf tests which fail when cross compiling
cat > config.cache <<EOF
gl_cv_func_wcwidth_works=yes
ac_cv_func_fnmatch_gnu=yes
EOF

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --cache-file=config.cache

make
