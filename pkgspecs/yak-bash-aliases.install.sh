#!/bin/bash
set -Eeo pipefail

# HACK SCALE: MINOR
#
# Deleting /bin/sh allows it to be created if it already exists.  The tools2
# base distribution contains a /bin/sh alias, which makes doing this or fixing
# the tools2 dependency scripts necessary.  Fixing the dependency scripts will
# take a good while, so this is the easy way out in the meantime.
#
# This will break if/when the package manager checks for file ownership
# conflicts before allowing packages to be installed...
if [[ -e "/bin/sh" ]]
then
  echo "EVIL HACK in action: overwriting /bin/sh" >&2
  rm -v /bin/sh
fi

# The init scripts specify /bin/sh.
ln -sv /bin/bash /bin/sh
