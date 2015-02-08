#!/bin/bash
set -Eeo pipefail
source /cross-tools/env.sh
version="$(</root/version)"
cd "/root/pkg-config-lite-$version"
make install
