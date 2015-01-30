#!/bin/bash
set -Eeo pipefail
version="$(</root/version)"
cd /root/gmp-*/
make install
