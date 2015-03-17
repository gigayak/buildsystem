#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   Glibc needs this for the pthreads library to work.
ln -sv /tools/i686/lib/libgcc_s.so{,.1} ${CLFS}/usr/lib

# Per CLFS book:
#   This is needed by several tests in Glibc's test suite, as well as for C++
#   support in GMP.
ln -sv /tools/i686/lib/libstdc++.so{.6,} ${CLFS}/usr/lib

# Per CLFS book:
#   This prevents a /tools reference that would otherwise be in
#   /usr/lib/libstdc++.la after GCC is installed.
sed -e 's@tools/i686@usr@' \
  /tools/i686/lib/libstdc++.la \
  > ${CLFS}/usr/lib/libstdc++.la

