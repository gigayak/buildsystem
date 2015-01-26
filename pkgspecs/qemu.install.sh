#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd "/root/qemu-$version"
make install
