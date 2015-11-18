#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep wget
dep tar
dep gcc

# http://stackoverflow.com/a/28379059
dep openssl-devel
