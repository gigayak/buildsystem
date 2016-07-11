#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# C++ program, so it links to glibc and libstdc++
dep glibc
dep gcc # for libstdc++ :[

# ./configure asked for headers, so assume we link the following:
dep zlib
dep glib
