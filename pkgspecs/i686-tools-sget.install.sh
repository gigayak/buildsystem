#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cp -v /root/workspace/bin/linux_386/* "$CLFS/tools/i686/bin/"
