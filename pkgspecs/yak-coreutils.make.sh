#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=8.25
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/coreutils/coreutils-$version.tar.xz"
wget "$url"

tar -Jxf "coreutils-$version.tar.xz"
cd coreutils-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

configure_flags=()
configure_flags+=(--prefix="/usr")
configure_flags+=(--libexecdir="/usr/$lib")
configure_flags+=(--libdir="/usr/$lib")
configure_flags+=(--enable-no-install-program="kill,uptime")
configure_flags+=(--enable-install-program="hostname")

configure_command=()
# FORCE_UNSAFE_CONFIGURE makes configure run as uid 0, as it has an
# explicit check to see if you're compiling as root.
configure_command+=(env FORCE_UNSAFE_CONFIGURE=1)
configure_command+=(./configure)
configure_command+=("${configure_flags[@]}")

echo "Configuring with ${configure_command[*]}" >&2
"${configure_command[@]}"

make
