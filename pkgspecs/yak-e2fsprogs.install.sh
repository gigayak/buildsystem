#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/build
make install
make install-libs
