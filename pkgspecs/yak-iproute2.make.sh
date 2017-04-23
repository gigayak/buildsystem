#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=4.0.0
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-$version.tar.gz"
wget --no-check-certificate "$url"
tar -zxf *.tar.*

cd *-*/

# Most people don't need arpd, and won't want Berkeley DB.
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
make
