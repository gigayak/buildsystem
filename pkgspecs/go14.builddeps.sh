#!/bin/bash
set -Eeo pipefail

echo wget # to fetch package
echo tar # to extract package

# Development tools, to build with
cat <<EOF
autoconf
automake
binutils
bison
flex
gcc
gcc-c++
gettext
libtool
make
patch
pkgconfig
redhat-rpm-config
rpm-build
EOF

