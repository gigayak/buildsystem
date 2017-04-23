#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

# Per CLFS book:
#   When the kernel boots the system, it requires the presence of a few device
#   nodes, in particular the console and null devices. The device nodes will be
#   created on the hard disk so that they are available before udev has been
#   started, and additionally when Linux is started in single user mode (hence
#   the restrictive permissions on console).
mknod -m 0600 ${CLFS}/dev/console c 5 1
mknod -m 0666 ${CLFS}/dev/null c 1 3
