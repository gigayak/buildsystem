#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep go
dep gcc

dep filesystem-skeleton
dep vim-enhanced
dep vim-go

dep git
dep internal-ca-certificates

dep ssh-dev-keys-client
