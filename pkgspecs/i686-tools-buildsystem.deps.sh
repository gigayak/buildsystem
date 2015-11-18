#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep i686-tools-env

# To fetch packages in deps/builddeps scripts.
dep i686-tools-wget

# Used for string transmogrification throughout.
dep i686-tools-sed

dep i686-tools-findutils
dep i686-tools-grep

# Used to identify changed files.
dep i686-tools-rsync
