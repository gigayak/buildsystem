#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/gettext-*/

# Bit of a weird install - we just want ONE binary.
cd gettext-tools/
cp -v src/msgfmt /tools/i686/bin
