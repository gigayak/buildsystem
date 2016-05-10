#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/config.sh"
source "$(DIR)/escape.sh"

for var in "${!_CONFIG_DESCRIPTIONS[@]}"
do
  echo set_config "$(sq "$var")" "$(sq "${_CONFIG_VALUES[$var]}")"
done
