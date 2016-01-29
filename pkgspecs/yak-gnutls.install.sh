#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd "/root/gnutls-$version"
make install

# See make.sh for the dirty details on this line.
rm -rf /usr/share/info
