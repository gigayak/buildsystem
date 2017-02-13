#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=2.7.10
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.python.org/ftp/python/$version/Python-$version.tgz"
wget --no-check-certificate "$url"
tar -xf *.tgz

# For some reason, shared libraries are not built for Python by default.
# This results in the following zany link-time error:
#   /usr/lib/libpython2.7.a(abstract.o): relocation R_X86_64_32S against 
#   _Py_NotImplementedStruct' can not be used when making a shared object;
#   recompile with -fPIC /usr/local/lib/libpython2.7.a: could not read
#   symbols: Bad value collect2: ld returned 1 exit status 
# Looks like the docker-library folks have faced confusion around this issue
# as well, per GitHub bug #21:
#   https://github.com/docker-library/python/issues/21
# Curiously, that bug mentions that most distributions build and install
# Python /twice/ - once statically, to have a fast /usr/bin/python, and once
# with shared libraries, to allow for stuff that links against the shared
# library to work.  This seems... more than unintuitive, so we're breaking
# ranks here a little bit by installing a single instance of Python with
# shared libraries.  This will slow the primary interpreter - but Python is
# pretty slow as is (GIL, etc), so hopefully this won't cause tremendous
# issues.
cd *-*/
./configure \
  --prefix="/usr" \
  --enable-shared
make
