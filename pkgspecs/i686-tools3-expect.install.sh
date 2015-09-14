#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/expect*/
make SCRIPTS="" install
