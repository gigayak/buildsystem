#!/bin/bash
set -Eeo pipefail
cd /root/gcc-build
make install

# Per CLFS: "Install the libiberty header file that is needed by some packages"
# TODO: Why isn't this installed by make install?
cp -v ../gcc-4*/include/libiberty.h /usr/include/

# Per CLFS:
#   Some packages expect the C preprocessor to be installed in the /lib directory.
# (Make sure to clean up the package we're overwriting first!)
rm -fv /lib/cpp
ln -sv ../usr/bin/cpp /lib

# Per CLFS:
#   Many packages use the name `cc` to call the C compiler.
# (Make sure to clean up the package we're overwriting first!)
rm -fv /usr/bin/cc
ln -sv gcc /usr/bin/cc
