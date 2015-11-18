#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep go-proxy

dep internal-ca-certificates
