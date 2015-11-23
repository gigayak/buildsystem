#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep go
dep gcc

dep rootfiles
dep vim-enhanced
dep vim-go

dep git
dep internal-ca-certificates

dep ssh-dev-keys-client
