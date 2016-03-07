#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# ./configure asked for headers, so assume we link the following:
dep zlib
dep glib2
