#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd "$YAK_WORKSPACE"/bzip2-*/
make PREFIX=/tools/i686 install
