#!/bin/bash
set -Eeo pipefail

# To fetch packages in deps/builddeps scripts.
echo wget
echo internal-ca-certificates

# Used in flag parsing. (Provides /usr/bin/getopt.)
echo util-linux-ng

# Used for string transmogrification throughout.
echo sed

echo findutils
echo grep

# Used to identify changed files.
echo rsync
