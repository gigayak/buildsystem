#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Now we will move some of the utilities to /usr/bin to meet FHS compliance:
mv -v /bin/{gzexe,uncompress} /usr/bin
mv -v /bin/z{egrep,cmp,diff,fgrep,force,grep,less,more,new} /usr/bin

