#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make -C src install
