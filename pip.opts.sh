#!/bin/bash
set -Eeo pipefail

pkg_name="$(echo "$PKG_NAME" | sed -re 's@^python-@@g')"

pip show "$pkg_name" \
  | grep 'Name:' \
  | awk '{print $2}' \
  | sed -re 's@^@--provides\n@g'
