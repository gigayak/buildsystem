#!/bin/bash
set -Eeo pipefail

#version=3.1.1
version=2.7.1 # gnutls does not support 3.0 and up
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/nettle/nettle-$version.tar.gz"

cd /root
wget "$url"
tar -zxf *.tar.gz
cd *-*/

./configure --prefix=/usr
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
#rm -rf /usr/share/info
