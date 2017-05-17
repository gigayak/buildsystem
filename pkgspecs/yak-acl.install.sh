#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*-*/
make install-dev
make install-lib
make install
