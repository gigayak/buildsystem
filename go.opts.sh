#!/bin/bash
set -Eeo pipefail

pkg_name="$(echo "$PKG_NAME" | sed -re 's@^go-@@g')"

echo -en "--provides\n$pkg_name\n"
