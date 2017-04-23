#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=8.23
echo "$version" > "$YAK_WORKSPACE/version"
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
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --enable-install-program=hostname \
  --cache-file=config.cache

# Per CLFS book (2.1.0, applying to coreutils 8.21):
#   Apply a sed to allow completion of the build.
#
# In my experience, not doing this causes this failure:
#   help2man: can't get `--help' info from man/chroot.td/chroot
cp -v Makefile{,.orig}
sed \
  -e 's/^#run_help2man\|^run_help2man/#&/' \
  -e 's/^\##run_help2man/run_help2man/' \
  Makefile.orig > Makefile
# This allows the above patch to work in 8.22 and above, as the dummy-man
# program gets a few extra arguments in the arguments.  This will probably
# cause malformed man pages - but we just want the build to proceed, as nobody
# will be reading the man pages in the intermediate tools distribution.
sed -r \
  -e 's@^(.*too many non-option arguments.*)$@@g' \
  -i man/dummy-man

make
