#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Move the xz binary, and several symlinks that point to it, into the /bin directory:
mv -v /usr/bin/{xz,lzma,lzcat,unlzma,unxz,xzcat} /bin

# Per CLFS book:
#   Finally, move the shared library to a more appropriate location, and recreate the
#   symlink pointing to it:
mv -v /usr/lib/liblzma.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

