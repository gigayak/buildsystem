#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-sed
dep i686-yak-coreutils # has reference to `dd` program