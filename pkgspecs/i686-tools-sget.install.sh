#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cp -v /root/workspace/bin/* "$CLFS/tools/i686/bin/"
