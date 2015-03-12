#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=2.88dsf
echo "$version" > /root/version
url="http://download.savannah.gnu.org/releases/sysvinit/sysvinit-$version.tar.bz2"
wget "$url"

tar -jxf "sysvinit-$version.tar.bz2"
patch="tools_updates-1.patch"
url="https://clfs.org/files/patches/3.0.0/SYSVINIT/sysvinit-$version-$patch"
wget "$url"
cd sysvinit-*/
# Per CLFS book:
#   Apply a patch to prevent installation of unneeded programs, and allow
#   sysvinit to be installed in /tools/i686:
patch -Np1 -i "../sysvinit-$version-$patch"

# Non-standard make process...
make -C src clobber
make -C src CC="$CC"
