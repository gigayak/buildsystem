#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=3.1.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://download.samba.org/pub/rsync/src/rsync-$version.tar.gz"
wget "$url"
tar -zxf *.tar.gz

cd *-*/

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make
