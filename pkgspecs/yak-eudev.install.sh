#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Create a directory for storing firmware that can be loaded by udev:
install -dv /lib/firmware

# Per CLFS book:
#   Create a dummy rule so that Eudev will name ethernet devices properly for
#   the system.
# TODO: Is this really needed?  What is the new default?
echo "# dummy, so that network is once again on eth*" > \
  /etc/udev/rules.d/80-net-name-slot.rules
