#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*-*/build_unix/
make install
