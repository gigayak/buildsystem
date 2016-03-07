#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/debianutils*/
make install
