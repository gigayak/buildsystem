#!/bin/bash
set -Eeo pipefail

cd /root/*-*/
make install

# Per CLFS book:
#   Move less to /bin:
mv -v /usr/bin/less /bin

