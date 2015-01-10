#!/bin/bash
set -Eeo pipefail

pkg_name="$(echo "$PKG_NAME" | sed -re 's@^python-@@g')"

pip show "$pkg_name" \
  | grep 'Version:' \
  | awk '{print $2}'
