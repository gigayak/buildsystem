#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*-*/
# TODO: install documentation and stuff
make prefix=/usr install
