#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

# This will force all dep files to be marked as "installed", even
# though many of them are unchanged.  As a result, the package will
# contain all of the files contained in tools2-gcc-aliases, which
# makes this package a modified form.  This would cause packaging
# conflicts - but tools2 gcc-aliases is a builddep, not a runtime dep,
# so the two should never be installed simultaneously making the issue
# moot.
#
# This package exists simply to prevent tools2 gcc from being
# installed on top of tools3 gcc, which might cause major issues.
cp -v "/.installed_pkgs/${YAK_TARGET_ARCH}-tools2:gcc-aliases" \
  "$YAK_WORKSPACE/extra_installed_paths"

