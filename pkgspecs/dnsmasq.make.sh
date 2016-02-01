#!/bin/bash
set -Eeo pipefail

version=2.72
echo "$version" > /root/version
url="http://www.thekelleys.org.uk/dnsmasq/dnsmasq-$version.tar.gz"

cd /root
wget "$url"
tar -zxf *.tar.gz
cd *-*/

make PREFIX=/usr

