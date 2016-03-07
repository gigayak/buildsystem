#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Move the killall and fuser programs to the location specified by the FHS:
mv -v /usr/bin/fuser /bin
mv -v /usr/bin/killall /bin
