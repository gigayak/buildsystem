#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"/*-*/
make install

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

# Per CLFS book:
#   Move the xz binary, and several symlinks that point to it, into the /bin directory:
mv -v /usr/bin/{xz,lzma,lzcat,unlzma,unxz,xzcat} /bin

# Per CLFS book:
#   Finally, move the shared library to a more appropriate location, and recreate the
#   symlink pointing to it:
mv -v "/usr/$lib"/liblzma.so.* "/$lib"
ln -sfv "../../$lib/$(readlink "/usr/$lib/liblzma.so")" "/usr/$lib/liblzma.so"

