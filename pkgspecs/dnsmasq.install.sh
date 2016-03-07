#!/bin/bash
set -Eeo pipefail

version="$(<"$YAK_WORKSPACE/version")"
cd "$YAK_WORKSPACE"/*-*/
make PREFIX=/usr install
