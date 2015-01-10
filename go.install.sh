#!/bin/bash
set -Eeo pipefail

cd "/root/$PKG_PATH/bin"
cp -rv * /usr/bin/
