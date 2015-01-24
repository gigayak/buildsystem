#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd "/root/protobuf-$version"
make install
