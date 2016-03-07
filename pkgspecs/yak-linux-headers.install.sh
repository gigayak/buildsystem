#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/linux-*/
make INSTALL_HDR_PATH=/usr headers_install
