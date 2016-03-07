#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/zlib-*/
make install
