#!/bin/bash
set -Eeo pipefail
cd /root/*/
make install

# TODO: CLFS book instructs you to symlink /usr/bin/perl to
#   /tools/i686/bin/perl here.  If absolutely needed, this should be
#   in an i686-tools3-perl-aliases package.
