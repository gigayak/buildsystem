#!/bin/bash
set -Eeo pipefail
cd /root/*/
make install

# Per CLFS book:
#   Many packages that use Ncurses will compile just fine against the widechar
#   libraries, but won't know to look for them. Create linker scripts and
#   symbolic links to allow older and non-widec compatible programs to build
#   properly:
for lib in curses ncurses form panel menu
do
  echo "INPUT(-l${lib}w)" > "/usr/lib/lib${lib}.so"
  ln -sfv "lib${lib}w.a" "/usr/lib/lib${lib}.a"
done
ln -sfv libncursesw.so /usr/lib/libcursesw.so
ln -sfv libncursesw.a /usr/lib/libcursesw.a
ln -sfv libncurses++w.a /usr/lib/libncurses++.a
ln -sfv ncursesw5-config /usr/bin/ncurses5-config
