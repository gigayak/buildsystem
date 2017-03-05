#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*/tools/build
b2 install --prefix=/usr
