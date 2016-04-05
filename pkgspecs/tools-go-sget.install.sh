#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cp -v "$YAK_WORKSPACE/workspace/bin/linux_386"/* "$CLFS/tools/i686/bin/"
