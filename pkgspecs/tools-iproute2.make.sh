#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=4.0.0
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-$version.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/

# Most people don't need arpd, and won't want Berkely DB.
#
# Per LFS book:
#   The arpd binary included in this package is dependent on Berkeley DB.
#   Because arpd is not a very common requirement on a base Linux system, remove
#   the dependency on Berkeley DB by applying the commands below. If the arpd
#   binary is needed, instructions for compiling Berkeley DB can be found in the
#   BLFS Book at
#   http://www.linuxfromscratch.org/blfs/view/svn/server/databases.html#db.
cp -v misc/Makefile{,.orig}
sed -e '/^TARGETS/s@arpd@@g' misc/Makefile.orig > misc/Makefile
cp -v Makefile{,.orig}
sed -e /ARPD/d Makefile.orig > Makefile
cp -v man/man8/Makefile{,.orig}
sed -e 's/arpd.8//' man/man8/Makefile.orig > man/man8/Makefile

./configure
make CC="$CC"
