#!/bin/bash
set -Eeo pipefail

echo i686-tools-env

# To fetch packages in deps/builddeps scripts.
echo i686-tools-wget

# Used for string transmogrification throughout.
echo i686-tools-sed

echo i686-tools-findutils
echo i686-tools-grep

# Used to identify changed files.
echo i686-tools-rsync
