#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd "/root/file-$version"
make install
