#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"

recursive_umount "$@"
