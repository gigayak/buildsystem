#!/bin/bash
set -Eeo pipefail

sed -r \
  -e 's@^python-Workzeug(.*)$@python-Werkzeug\1@g' \
  -i \
  "$YAK_WORKSPACE/deplist.txt"
