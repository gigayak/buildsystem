#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh

version="$(</root/version)"
cd "/root/file-$version"
make install
