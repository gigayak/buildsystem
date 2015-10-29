#!/bin/bash
set -Eeo pipefail

echo wget
echo tar
echo gcc
echo openssl-devel
echo libcurl-devel
echo expat-devel
echo perl-devel
echo tcl-devel
echo gettext

# git has waaaay too much documentation
echo asciidoc

# XML documentation seems to fail out-of-box:
#   https://bugzilla.redhat.com/show_bug.cgi?id=1143060
#echo xmlto
#echo docbook-dtds
