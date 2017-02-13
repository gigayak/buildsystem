#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/kconfig.sh"
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=1.23.2
echo "$version" > "$YAK_WORKSPACE/version"
url="http://www.busybox.net/downloads/busybox-$version.tar.bz2"
wget "$url"

tar -jxf *.tar.bz2
cd *-*/

kconfig_init CROSS_COMPILE="${CLFS_TARGET}-" allnoconfig
# TODO: add initrd dependencies here
sed -r \
  -e 's@^(CONFIG_PREFIX=).*$@\1"'"$CLFS_ROOT"'/tools/'"$YAK_TARGET_ARCH"'"@g' \
  -i .config
make CROSS_COMPILE="${CLFS_TARGET}-"
