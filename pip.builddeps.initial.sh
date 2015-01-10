#!/bin/bash
set -Eeo pipefail
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pkg_name="$(echo "$PKG_NAME" | sed -re 's@^python-@@g')"

# Development tools, for C-language Python extensions.
cat <<EOF
autoconf
automake
binutils
bison
flex
gcc
gcc-c++
gettext
libtool
make
patch
pkgconfig
redhat-rpm-config
rpm-build
python-devel
EOF

# pip and setuptools
# These NEED to be installed for the next step :(
# TODO: There should be a better way of doing this -- perhaps an inline
#       "install this package and build if necessary" command?
yum -y --nogpgcheck install python-distribute python-pip >&2

mkdir /root/deps
pip install \
  --download=/root/deps \
  "$pkg_name" \
  > /root/deplist.txt.in.1
f=deplist.txt.in.1
echo "$f:" >&2
cat "/root/$f" >&2

grep -e '^Downloading' /root/deplist.txt.in.1 > /root/deplist.txt.in.2 || true
f=deplist.txt.in.2
echo "$f:" >&2
cat "/root/$f" >&2

awk '{print $2}' /root/deplist.txt.in.2 > /root/deplist.txt.in.3
f=deplist.txt.in.3
echo "$f:" >&2
cat "/root/$f" >&2
grep -ve "^$pkg_name\$" /root/deplist.txt.in.3 > /root/deplist.txt.in.4 || true
f=deplist.txt.in.4
echo "$f:" >&2
cat "/root/$f" >&2

# Prepend python- prefix
# Remove version spec
# Lowercase dependencies
sed -r \
  -e 's@^@python-@g' \
  -e 's@[>=<]+[0-9.]+@@g' \
  /root/deplist.txt.in.4 \
  | tr '[:upper:]' '[:lower:]' \
  > /root/deplist.txt
f=deplist.txt
echo "$f:" >&2
cat "/root/$f" >&2
# TODO: remove all of these cats

rm -rf /root/deplist.txt.in.*
# OR'ing with true above is to prevent grep from causing a pipeline failure
# when it can't find any matching lines (say--when no dependencies exist).
