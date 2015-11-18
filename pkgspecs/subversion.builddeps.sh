#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep wget
dep tar
dep gcc
dep sqlite-devel
dep zlib-devel
