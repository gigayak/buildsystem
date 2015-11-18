#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep wget
dep tar
dep gcc
dep openssl-devel
dep libcurl-devel
dep expat-devel
dep perl-devel
dep tcl-devel
dep gettext

# git has waaaay too much documentation
dep asciidoc

# XML documentation seems to fail out-of-box:
#   https://bugzilla.redhat.com/show_bug.cgi?id=1143060
#echo xmlto
#echo docbook-dtds
