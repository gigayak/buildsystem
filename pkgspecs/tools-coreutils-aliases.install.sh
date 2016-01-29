#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   This pathname is hard-coded into Glibc's configure script.
ln -sv /tools/i686/bin/cat ${CLFS}/bin

# Per CLFS book:
#   This is to satisfy one of the tests in Glibc's test suite, which expects
#   /bin/echo.
ln -sv /tools/i686/bin/echo ${CLFS}/bin

# Per CLFS book:
#   Some configure scripts, particularly Glibc's, have this pathname hard-coded.
ln -sv /tools/i686/bin/pwd ${CLFS}/bin

# Per CLFS book:
#   This pathname is hard-coded into Expect, therefore it is needed for Binutils
#   and GCC test suites to pass.
ln -sv /tools/i686/bin/stty ${CLFS}/bin
