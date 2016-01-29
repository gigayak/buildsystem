#!/bin/bash
set -Eeo pipefail

cd /root
version=2.3.20
echo "$version" > /root/version
urldir="http://download.savannah.gnu.org/releases/man-db"
url="$urldir/man_db-${version}.tar.gz"
wget "$url"
tar -zxf *.tar.*

cd *-*/
# --disable-setuid is prescribed by the CLFS book, but does not work in the
# latest release of man-db due to a debug output line using the effective user
# ID and real user ID regardless of whether --disable-setuid is set - and the
# effective and real user ID variables are only initialized when this flag is
# not present.
#
# Something tells me that --disable-setuid is not necessarily a mainstream
# configuration option...
#
# TODO: upstream a fix to this issue by adding an #ifdef SECURE_MAN_ID guard
# to the debug output in question.
#
# TODO: double check that doing this isn't going to cause man to be setuid root
./configure \
  --prefix=/usr \
  --libexecdir=/usr/lib \
  --mandir="/usr/share/doc/man-db-${version}" \
  --sysconfdir=/etc \
  --with-browser=/usr/bin/lynx \
  --with-vgrind=/usr/bin/vgrind \
  --with-grap=/usr/bin/grap
make
