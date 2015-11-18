#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep gnutls # to generate certs
dep coreutils # basename et al
