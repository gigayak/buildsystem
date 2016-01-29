#!/bin/bash
set -Eeo pipefail
cd /root/binutils-build
make tooldir=/usr install
