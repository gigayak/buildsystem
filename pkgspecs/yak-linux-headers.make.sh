#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=3.18.3
echo "$version" > "$YAK_WORKSPACE/version"
# kernel.org will redirect you to an HTTPS URL whether you like it or not.
# TODO: This is GOOD.  Not having certificates installed here is BAD.
#   Figure out how to populate a bunch of root certificates for the stage2
#   image!
url="https://www.kernel.org/pub/linux/kernel/v3.x/linux-$version.tar.xz"
wget --no-check-certificate "$url"

tar -Jxf "linux-$version.tar.xz"
cd "linux-$version"
make mrproper
make headers_check
