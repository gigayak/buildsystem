#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To fetch packages in deps/builddeps scripts.
dep wget
dep internal-ca-certificates

# Used in flag parsing. (Provides /usr/bin/getopt.)
dep util-linux-ng

# Used for string transmogrification throughout.
dep sed

dep findutils
dep grep

# Used to identify changed files.
dep rsync
