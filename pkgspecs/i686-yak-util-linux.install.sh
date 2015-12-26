#!/bin/bash
set -Eeo pipefail
cd /root/*/
make install

# Per CLFS book:
#   Move the logger binary to /bin as it is needed by the CLFS Bootscripts
#   package
# TODO: Maybe... don't rely on it in the boot scripts?
mv -v /usr/bin/logger /bin
