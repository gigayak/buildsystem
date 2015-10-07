#!/bin/bash
set -Eeo pipefail

# Per CLFS book:
#   Now we adjust GCC's specs so that they point to the new dynamic
#   linker.
gcc \
  -dumpspecs \
| perl \
  -p \
  -e 's@/tools/i686/lib/ld@/lib/ld@g;' \
  -e 's@\*startfile_prefix_spec:\n@$_/usr/lib/ @g;' \
  > "$(dirname "$(gcc --print-libgcc-file-name)")/specs"
