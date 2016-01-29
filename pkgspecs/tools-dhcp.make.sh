#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=4.3.2
echo "$version" > /root/version
url="http://ftp.isc.org/isc/dhcp/$version/dhcp-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

# Some options automatically fail when cross compiling :(
cat > config.cache <<'EOF'
ac_cv_file__dev_random=yes
EOF

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}" \
  --cache-file=config.cache
make
