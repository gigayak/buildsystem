#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/arch.sh"
source "$DIR/mkroot.sh"

mkroot dir
tar \
  --numeric-owner \
  --directory="$dir" \
  --exclude="proc" \
  --exclude="dev" \
  -cf "$DIR/base_image.tar" "."

