#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/grub-*/
make install
