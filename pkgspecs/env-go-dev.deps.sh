#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

cat <<EOF
go
gcc

rootfiles
vim-enhanced
vim-go

git
internal-ca-certificates

ssh-dev-keys-client
EOF
