#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$BUILDTOOLS/all.sh"

pkg_name="$(echo "$PKG_NAME" | sed -re 's@^python-@@g')"

# Development tools, for C-language Python extensions.
dep autoconf
dep automake
dep binutils
dep bison
dep flex
dep gcc
dep gcc-c++
dep gettext
dep libtool
dep make
dep patch
dep pkgconfig
dep python-devel

# NOTE: /root/deplist.txt will be exported in pip.builddeps.final.txt!

mkdir /root/deps
pip install \
  --download=/root/deps \
  "$pkg_name" \
  > /root/deplist.txt.in.1

grep \
  -e '^\s*Downloading' \
  /root/deplist.txt.in.1 \
  > /root/deplist.txt.in.2 \
  || true

awk '{print $2}' /root/deplist.txt.in.2 > /root/deplist.txt.in.3

# Prepend python- prefix
# Remove .tar.gz suffix
# Remove version spec
# Lowercase dependencies
sed -r \
  -e 's@^@python-@g' \
  -e 's@-[0-9\.]+-py[0-9]+.*\.whl@@g' \
  -e 's@-[0-9\.]+\.tar\.gz@@g' \
  -e 's@[>=<]+[0-9.]+@@g' \
  /root/deplist.txt.in.3 \
  | tr '[:upper:]' '[:lower:]' \
  > /root/deplist.txt.in.4

# If we don't wait until we strip .tar.gz / .whl / etc, then removing our own
# package name can fail due to the extra cruft, causing a big messy infinite
# loop.
grep \
  -vie "^python-$pkg_name\$" \
  /root/deplist.txt.in.4 \
  > /root/deplist.txt \
  || true

rm -rf /root/deplist.txt.in.*
# OR'ing with true above is to prevent grep from causing a pipeline failure
# when it can't find any matching lines (say--when no dependencies exist).
