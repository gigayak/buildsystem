#!/bin/bash
set -Eeo pipefail

pkg_name="$(echo "$PKG_NAME" | sed -re 's@^python-@@g')"
pip install $pkg_name
