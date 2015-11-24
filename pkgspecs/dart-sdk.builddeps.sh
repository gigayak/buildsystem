#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# From build instructions (needed to install depot_tools)
dep git
dep subversion
dep python27 # python 2.6 won't work for depot_tools
dep curl

# Resolves an ImportError during build:
#
#     ImportError: No module named _sysconfigdata_nd
#
# This is apparently due to an outdated version of distutils.  Installing
# pip and distribute is the "canonical" fix (bad pun):
#
#     https://bugs.launchpad.net/ubuntu/+source/python2.7/+bug/1115466
dep python-distribute
dep python-pip

# Needed to download and extract source
dep wget
dep tar

# From build instructions (needed to build dart)
dep make
if [[ "$HOST_OS" == "centos" ]]
then
  # CentOS build of GCC is too old to build dart.
  dep gcc-local
else
  # Other OSes should have a recent-enough GCC.
  dep gcc
fi

# Additional stuff needed to build dart
dep glibc-devel
