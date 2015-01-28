#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd "/root/m4-$version"
make install
