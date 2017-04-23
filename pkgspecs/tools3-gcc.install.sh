#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

# Per CLFS book:
#   Now we adjust GCC's specs so that they point to the new dynamic
#   linker.
gcc \
  -dumpspecs \
| perl \
  -p \
  -e 's@/tools/'"${YAK_TARGET_ARCH}"'/lib/ld@/lib/ld@g;' \
  -e 's@\*startfile_prefix_spec:\n@$_/usr/lib/ @g;' \
  > "$(dirname "$(gcc --print-libgcc-file-name)")/specs"
