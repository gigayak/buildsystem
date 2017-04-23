#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh
cd "$YAK_WORKSPACE"/eudev-*/
make install

# Per CLFS book:
#   Create a directory for storing firmware that can be loaded by udev:
install -dv "/tools/${YAK_TARGET_ARCH}/lib/firmware"

# Per CLFS book:
#   Create a dummy rule so that Eudev will name ethernet devices properly for
#   the system.
# TODO: Is this really needed?  What is the new default?
echo "# dummy, so that network is once again on eth*" > \
  "/tools/${YAK_TARGET_ARCH}/etc/udev/rules.d/80-net-name-slot.rules"
