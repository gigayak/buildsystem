#!/bin/bash
set -Eeo pipefail
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
#   Many packages that use Ncurses will compile just fine against the widechar
#   libraries, but won't know to look for them. Create linker scripts and
#   symbolic links to allow older and non-widec compatible programs to build
#   properly:
for libname in curses ncurses form panel menu
do
  echo "INPUT(-l${libname}w)" > "/usr/$lib/lib${libname}.so"
  ln -sfv "lib${libname}w.a" "/usr/$lib/lib${libname}.a"
done
ln -sfv libncursesw.so "/usr/$lib/libcursesw.so"
ln -sfv libncursesw.a "/usr/$lib/libcursesw.a"
ln -sfv libncurses++w.a "/usr/$lib/libncurses++.a"
ln -sfv ncursesw5-config "/usr/bin/ncurses5-config"
