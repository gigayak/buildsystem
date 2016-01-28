#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# This file sources the world!
source "$(DIR)/tool_names.sh"
source "$(DIR)/dependency_translation.sh"
