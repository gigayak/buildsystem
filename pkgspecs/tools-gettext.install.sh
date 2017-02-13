#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd "$YAK_WORKSPACE"/gettext-*/

# Bit of a weird install - we just want ONE binary.
cd gettext-tools/
cp -v "src/msgfmt" "/tools/${YAK_TARGET_ARCH}/bin"
