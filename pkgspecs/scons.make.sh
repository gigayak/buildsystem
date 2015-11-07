#!/bin/bash
set -Eeo pipefail

version=2.4.0
echo "$version" > /root/version
cd /root
wget "http://prdownloads.sourceforge.net/scons/scons-$version.tar.gz"
tar -xf *.tar.*
