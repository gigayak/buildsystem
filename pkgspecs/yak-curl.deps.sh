#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep gnutls
dep ca-certificates
dep internal-ca-certificates
dep zlib
