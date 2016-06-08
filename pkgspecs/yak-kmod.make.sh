#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=20
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-$version.tar.xz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
./configure \
  --prefix=/usr \
  --bindir=/bin \
  --sysconfdir=/etc \
  --with-rootlibdir=/lib \
  --with-zlib \
  --with-xz
make

cat >> "$YAK_WORKSPACE/extra_installed_paths" <<'EOF'
/bin/lsmod
/bin/rmmod
/bin/insmod
/bin/modinfo
/bin/modprobe
/bin/depmod
EOF
