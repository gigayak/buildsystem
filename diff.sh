#!/bin/bash
set -Eeo pipefail

# --archive == -rlptgoD
# -r = --recursive
# -l = --links = copy symlinks as symlinks
# -p = --perms = preserve permissions
# -t = --times = preserve mtimes
# -g = --group = preserve group
# -o = --owner = preserve owner
# -D = --devices --specials
#      --devices = preserve device files (superuser only)
#      --specials = preserve special files
# --verbose outputs change list and summary
# --itemize-changes outputs just the change list
rsync \
  --dry-run \
  --archive \
  --itemize-changes \
  /tmp/tmp.suyfYpp3zg cache/baseroot \
  > distribute.diff
