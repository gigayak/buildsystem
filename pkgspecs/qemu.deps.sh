#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# ./configure asked for headers, so assume we link the following:
dep zlib
dep glib2
