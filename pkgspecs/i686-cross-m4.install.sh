#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

version="$(</root/version)"
cd "/root/m4-$version"
make install
