#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="2.21"
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/glibc/glibc-$version.tar.gz"
wget "$url" --progress=dot:giga
tar -zxf "glibc-$version.tar.gz"
cd glibc-*/

# Per CLFS book:
#   At the end of the installation, the build system will run a sanity test to
#   make sure everything installed properly. This script performs its tests by
#   attempting to compile test programs against certain libraries. However it
#   does not specify the path to ld.so, and our toolchain is still configured
#   to use the one in /tools. The following set of commands will force the
#   script to use the complete path of the new ld.so that was just installed.
LINKER="$(readelf -l "/tools/$YAK_TARGET_ARCH/bin/bash" \
  | sed -n 's@.*interpret.*/tools/'"$YAK_TARGET_ARCH"'\(.*\)]$@\1@p')"
sed -i "s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=${LINKER} -o|" \
  scripts/test-installation.pl
unset LINKER

# "Apply the following sed so the tzselect script works properly"
# Per CLFS book.
# TODO: Can this be removed safely?
cp -v timezone/Makefile{,.orig}
sed 's/\\$$(pwd)/`pwd`/' timezone/Makefile.orig > timezone/Makefile

# Yet another library demands we build outside of the source directory.
mkdir -v ../glibc-build
cd ../glibc-build

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac
# Cause ld-linux-x86_64-2.so to appear in /lib/ on 64-bit builds instead of
# /lib64/, so that we're in line with the Pure64 GCC configuration.
echo "slibdir=/$lib" >> configparms
# TODO: --enable-kernel is hard coded to an incorrect version here and in tools.
# TODO: Can any of these options be removed?
../glibc-*/configure \
  --prefix=/usr \
  --disable-profile \
  --enable-kernel=2.6.32 \
  --libdir="/usr/$lib" \
  --libexecdir="/usr/$lib/glibc" \
  --enable-obsolete-rpc

# --libexecdir=/usr/lib/glibc is explained by the CLFS book as:
#   This changes the location for hard links to the getconf utility from their
#   default of /usr/libexec to /usr/lib/glibc.
# TODO: Can that be removed safely?  Why would it be changed from default?

make

echo "Skipping tests, as they seem to fail in chroot contexts."
exit 0

# TODO: Figure out how to make the test suite work.
echo "STARTING TESTS NOW"
echo "The test suite should pass at this point."
make -k check 2>&1 \
  tee "$YAK_WORKSPACE/glibc-check-log"

if grep Error "$YAK_WORKSPACE/glibc-check-log" \
  | grep -v 'Error 1 (ignored)' >/dev/null 2>&1
then
  echo "Found failures.  grep for 'Error'." >&2
  exit 1
fi
