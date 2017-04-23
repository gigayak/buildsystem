#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/config.sh"

# TODO: Use a .gitignore-ed subdirectory if a global directory is not ready.
get_config LOCAL_STORAGE_PATH

