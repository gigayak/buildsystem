#!/bin/bash
set -Eeo pipefail

pkg_name="$(echo "$YAK_PKG_NAME" | sed -re 's@^python-@@g')"
pip install $pkg_name
