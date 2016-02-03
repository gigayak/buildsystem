#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# TODO: Use a .gitignore-ed subdirectory if a global directory is not ready.
echo "$( cd "$(DIR)/.." && pwd )/localstorage"

