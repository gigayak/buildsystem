#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep git
dep gcc
dep make
dep automake
dep autoconf
dep python
dep diffutils # cmp used in a build test
dep gperf # I think this is build time?  Could be runtime.
dep ruby # I think this is build time?  Could be runtime.
dep bison
dep flex
