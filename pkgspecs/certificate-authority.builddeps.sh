#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep curl
dep git
dep internal-ca-certificates
