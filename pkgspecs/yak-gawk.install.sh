#!/bin/bash
set -Eeo pipefail

cd /root/*-*/
make install

# Per CLFS book:
#   Install the documentation:
mkdir -v /usr/share/doc/gawk-4.1.3
cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.3

