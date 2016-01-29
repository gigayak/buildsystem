#!/bin/bash
set -Eeo pipefail

cd /root/linux-*/
make INSTALL_HDR_PATH=/usr headers_install
