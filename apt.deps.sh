#!/bin/bash
set -Eeo pipefail

apt-get install "$PKG_NAME" --dry-run \
  | sed -nre 's@^Inst (\S+)\s.*$@\1@gp' \
  | {
    grep -vE "^${PKG_NAME}\$" || true
  }
