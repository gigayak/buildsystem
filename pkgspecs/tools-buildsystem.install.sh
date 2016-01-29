#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root/workspace/*/
mkdir -pv "$CLFS/tools/i686/bin/buildsystem/"
cp -rv * "$CLFS/tools/i686/bin/buildsystem/"
