#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make SHLIB_LIBS=-lncurses htmldir=/usr/share/doc/readline-6.3 install

# Per CLFS book:
#   Now move the static libraries to a more appropriate location:
mv -v /lib/lib{readline,history}.a /usr/lib

# Per CLFS book:
#   Next, relink the dynamic libraries into /usr/lib and remove the .so files
#   in /lib.
ln -svf "../../lib/$(readlink /lib/libreadline.so)" /usr/lib/libreadline.so
ln -svf "../../lib/$(readlink /lib/libhistory.so)" /usr/lib/libhistory.so
rm -v /lib/lib{readline,history}.so

