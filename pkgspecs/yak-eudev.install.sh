#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make install

# Per CLFS book:
#   Create a directory for storing firmware that can be loaded by udev:
install -dv /tools/i686/lib/firmware

# Per CLFS book:
#   Create a dummy rule so that Eudev will name ethernet devices properly for
#   the system.
# TODO: Is this really needed?  What is the new default?
echo "# dummy, so that network is once again on eth*" > \
  /tools/i686/etc/udev/rules.d/80-net-name-slot.rules
