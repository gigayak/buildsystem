#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# C++ program, so it links to glibc and libstdc++
dep glibc
dep gcc # for libstdc++ :[

# ./configure asked for headers, so assume we link the following:
dep zlib
dep glib

# Picked up passively if not explicitly declared:
# qemu-system-i386: error while loading shared libraries: libgnutls.so.30:
# cannot open shared object file: No such file or directory
dep gnutls
