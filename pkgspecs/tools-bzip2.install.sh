#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/bzip2-*/
make PREFIX=/tools/i686 install
