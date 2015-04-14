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
#patch -Np1 -i "../sysvinit-$version-$patch"
cp -v src/Makefile{,.orig}
# TODO: The target-based sed deletions could be /.../d expressions.
sed -r \
  -e 's@^\s*last[o.]*:.*$@@g' \
  -e 's@^(\s*)ln -sf last.*$@\1echo nop >/dev/null; \\@g' \
  -e 's@last\S*@@g' \
  -e 's@^\s*mesg[o.]*:.*$@@g' \
  -e 's@mesg\S*@@g' \
  -e 's@^\s*sulogin[o.]*:.*$@@g' \
  -e 's@sulogin\S*@@g' \
  -e 's@^\s*utmpdump[o.]*:.*$@@g' \
  -e 's@utmpdump\S*@@g' \
  -e 's@^\s*mountpoint[o.]*:.*$@@g' \
  -e 's@mountpoint\S*@@g' \
  src/Makefile.orig > src/Makefile
cp -v src/paths.h{,.orig}
sed -r \
  -e 's@^(\#define\s+INITTAB\s+")[^"]+(".*$)@\1/tools/i686/etc/inittab\2@g' \
  src/paths.h.orig > src/paths.h

# Non-standard make process...
make -C src clobber
make -C src CC="$CC"
