#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep apr
dep apr-util
dep sqlite3
dep zlib
dep gnutls
dep serf
