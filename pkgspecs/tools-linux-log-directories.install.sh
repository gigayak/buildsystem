#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

# Per the CLFS book:
#   The login, agetty, and init programs (and others) use a number of log files
#   to record information such as who was logged into the system and when.
#   However, these programs will not write to the log files if they do not
#   already exist. Initialize the log files and give them proper permissions:
touch ${CLFS}/var/log/{btmp,lastlog,wtmp}
chgrp -v 13 ${CLFS}/var/log/lastlog
chmod -v 664 ${CLFS}/var/log/lastlog
chmod -v 600 ${CLFS}/var/log/btmp
