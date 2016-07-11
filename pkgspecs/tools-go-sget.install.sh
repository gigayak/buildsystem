#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

if [[ -e "$YAK_WORKSPACE/workspace/bin/linux_386" ]]
then
  cp -v "$YAK_WORKSPACE/workspace/bin/linux_386"/* "$CLFS/tools/i686/bin/"
else
  cp -v "$YAK_WORKSPACE/workspace/bin"/* "$CLFS/tools/i686/bin/"
fi
