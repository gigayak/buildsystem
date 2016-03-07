#!/bin/bash
set -Eeo pipefail

version=2.72
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.thekelleys.org.uk/dnsmasq/dnsmasq-$version.tar.gz"

cd "$YAK_WORKSPACE"
wget "$url"
tar -zxf *.tar.gz
cd *-*/

make PREFIX=/usr

