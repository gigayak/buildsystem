#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*/
make -f unix/Makefile prefix=/usr install
