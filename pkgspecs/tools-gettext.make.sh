#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=0.19.4
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/gettext/gettext-$version.tar.gz"
wget "$url"

tar -zxf "gettext-$version.tar.gz"
cd gettext-*/

# Per CLFS:
#   Only the programs in the gettext-tools directory need to be installed for
#   the temp-system.
# TODO: Why do we not need everything?
cd gettext-tools/

# ./configure fails when cross-compiling, like it always does...
echo "gl_cv_func_wcwidth_works=yes" > config.cache

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --disable-shared \
  --cache-file=config.cache

# From CLFS book
make -C gnulib-lib

# From http://comments.gmane.org/gmane.linux.lfs.beyond.devel/28249
# May fix:
#   ...: fatal error: ../intl/pluralx.c: No such file or directory
#   #include "../intl/pluralx.c"
make -C intl pluralx.c

# From CLFS book
make -C src msgfmt
