#!/bin/bash
set -Eeo pipefail
cd /root/build
make install
make install-libs
