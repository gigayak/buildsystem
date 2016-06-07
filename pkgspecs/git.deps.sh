#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep openssl
dep curl
dep expat
dep perl
dep tcl

# git looks up the current user in the passwd file for some reason - without
# this dependency, git clone fails with:
#
#     fatal: unable to look up current user in the passwd file: No such file
#     or directory
#
# No, I'm not entirely sure why.
dep linux-credentials
