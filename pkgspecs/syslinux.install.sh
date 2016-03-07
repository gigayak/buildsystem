#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/syslinux-*/
make install
