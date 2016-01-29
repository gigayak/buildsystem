#!/bin/bash
set -Eeo pipefail

cd /root
version=s20140519
echo "$version" > /root/version
url="https://github.com/iputils/iputils/archive/${version}.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
make \
  USE_CAP=no \
  TARGETS="clockdiff ping rdisc tracepath tracepath6 traceroute6"
