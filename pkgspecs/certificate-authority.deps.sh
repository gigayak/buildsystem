#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep gnutls # to generate certs
dep coreutils # basename et al
dep sed
