#!/bin/bash
set -Eeo pipefail

# This will force all GCC files to be marked as "installed", even
# though many of them are unchanged.  As a result, the package will
# contain all of the files contained in i686-tools2-gcc, which
# makes this package a modified form.  This would cause packaging
# conflicts - but i686-tools2-gcc is a builddep, not a runtime dep,
# so the two should never be installed simultaneously making the issue
# moot.
cp -v "/.installed_pkgs/i686-tools2:gcc" "$YAK_WORKSPACE/extra_installed_paths"

# Now, why would we want to output a modified form of i686-tools2-gcc?
# The pre-modification form is used to build all of the other tools3
# packages, with an LDD path in /tools.  This form will actually link
# against the main glibc - so it should be used for all non-stage2
# packages (aside from glibc).
