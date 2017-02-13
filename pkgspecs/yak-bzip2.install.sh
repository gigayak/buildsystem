#!/bin/bash
set -Eeo pipefail

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

cd "$YAK_WORKSPACE"/*-*/
make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* "/$lib"
ln -sv "../../$lib/libbz2.so.1.0" "/usr/$lib/libbz2.so"
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat
