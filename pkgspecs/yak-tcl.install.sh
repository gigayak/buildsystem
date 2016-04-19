#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/tcl*/
cd unix
make install

