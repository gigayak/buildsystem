#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

# Per CLFS book:
#   Glibc needs this for the pthreads library to work.
ln -sv "/tools/${YAK_TARGET_ARCH}/$lib/libgcc_s.so"{,.1} "${CLFS}/usr/$lib"

# Per CLFS book:
#   This is needed by several tests in Glibc's test suite, as well as for C++
#   support in GMP.
ln -sv "/tools/${YAK_TARGET_ARCH}/$lib/libstdc++.so"{.6,} "${CLFS}/usr/$lib"

# Per CLFS book:
#   This prevents a /tools reference that would otherwise be in
#   /usr/lib/libstdc++.la after GCC is installed.
sed -e 's@tools/'"$YAK_TARGET_ARCH"'@usr@' \
  "/tools/${YAK_TARGET_ARCH}/$lib/libstdc++.la" \
  > "${CLFS}/usr/$lib/libstdc++.la"

