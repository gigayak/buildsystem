#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make DOCDIR="/usr/share/doc/iproute2-$(<"$YAK_WORKSPACE/version")" install
