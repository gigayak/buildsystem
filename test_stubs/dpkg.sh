#!/bin/bash
set -Eeo pipefail

if (( "$#" < 1 ))
then
  echo "Usage: $(basename "$0") <options>" >&2
  echo "" >&2
  echo "Need at least one option flag (-i, -s)" >&2
  exit 1
fi

if [[ "$1" == "-i" ]]
then
  exit 0
fi

if [[ "$1" == "-s" ]]
then
  cat <<EOF
Package: libc6
Status: install ok installed
Priority: required
Section: libs
Installed-Size: 10493
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Architecture: amd64
Multi-Arch: same
Source: eglibc
Version: 2.19-0ubuntu6.6
Replaces: libc6-amd64
Provides: glibc-2.19-1
Depends: libgcc1
Suggests: glibc-doc, debconf | debconf-2.0, locales
Breaks: hurd (<< 1:0.5.git20140203-1), lsb-core (<= 3.2-27), nscd (<< 2.19)
Conflicts: prelink (<= 0.0.20090311-1), tzdata (<< 2007k-1), tzdata-etch
Conffiles:
 /etc/ld.so.conf.d/x86_64-linux-gnu.conf 593ad12389ab2b6f952e7ede67b8fbbf
Description: Embedded GNU C Library: Shared libraries
 Contains the standard libraries that are used by nearly all programs on
 the system. This package includes shared versions of the standard C library
 and the standard math library, as well as many others.
Homepage: http://www.eglibc.org
Original-Maintainer: GNU Libc Maintainers <debian-glibc@lists.debian.org>
EOF
  exit 0
fi

echo "$(basename "$0"): unsupported flag $1" >&2
exit 1
