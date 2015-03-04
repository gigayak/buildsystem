#!/bin/bash
set -Eeo pipefail

# Ensure we don't have collisions when creating our directory tree.
echo i686-tools-root
echo i686-tools-env

# We're gonna have to link to glibc, just like EVERYTHING will.
echo i686-tools-glibc
