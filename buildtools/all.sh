#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}

# This file sources the world!
source "$(DIR)/tool_names.sh"
source "$(DIR)/dependency_translation.sh"
