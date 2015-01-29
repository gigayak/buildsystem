#!/bin/bash
set -Eeo pipefail
version="$(</root/version)"
cd "/root/pkg-config-lite-$version"
make install
