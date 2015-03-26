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
#
# HACK SCALE: MINOR
#
# Prior to switching to .tar.gz intermediate package format, we would have used
# yum to get these.  Now, we don't have a local package manager available and
# installed.
#
# wget/curl are unavailable at this point, but Python is available.  We can
# download packages and extract them using Python... but it's hacky as heck.
#
# Note that this will immediately, horribly break if these were to have any
# dependencies... but they don't, so what could possibly go wrong?
python <<'EOF'
import urllib2, tarfile
pkgs = ['python-distribute', 'python-pip']
url_tpl = 'http://192.168.0.102/tgzrepo/{0}.tar.gz'
tar_tpl = '/root/{0}.tar.gz'
for p in pkgs:
  response = urllib2.urlopen(url_tpl.format(p))
  html = response.read()
  tar_file = tar_tpl.format(p)
  with open(tar_file, 'w') as f:
    f.write(html)
  tar_handle = tarfile.open(tar_file, 'r|gz')
  tar_handle.extractall("/")
  tar_handle.close()
  with open("/.installed_pkgs", "a") as f:
    f.write("{0}\n".format(p))
EOF

mkdir /root/deps
pip install \
  --download=/root/deps \
  "$pkg_name" \
  > /root/deplist.txt.in.1
f=deplist.txt.in.1
echo "$f:" >&2
cat "/root/$f" >&2

grep \
  -e '^\s*Downloading' \
  /root/deplist.txt.in.1 \
  > /root/deplist.txt.in.2 \
  || true
f=deplist.txt.in.2
echo "$f:" >&2
cat "/root/$f" >&2

awk '{print $2}' /root/deplist.txt.in.2 > /root/deplist.txt.in.3
f=deplist.txt.in.3
echo "$f:" >&2
cat "/root/$f" >&2

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
f=deplist.txt.in.4
echo "$f:" >&2
cat "/root/$f" >&2

# If we don't wait until we strip .tar.gz / .whl / etc, then removing our own
# package name can fail due to the extra cruft, causing a big messy infinite
# loop.
grep \
  -vie "^python-$pkg_name\$" \
  /root/deplist.txt.in.4 \
  > /root/deplist.txt \
  || true
f=deplist.txt
echo "$f:" >&2
cat "/root/$f" >&2
# TODO: remove all of these cats

rm -rf /root/deplist.txt.in.*
# OR'ing with true above is to prevent grep from causing a pipeline failure
# when it can't find any matching lines (say--when no dependencies exist).
