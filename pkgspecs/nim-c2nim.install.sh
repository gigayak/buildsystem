#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*-*/
cp -rv /.nimble/pkgs/c2nim-*/c2nim /usr/bin/
