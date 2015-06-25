#!/bin/bash
set -Eeo pipefail

cd /root/workspace/*/
mkdir -pv "/usr/bin/buildsystem/"
cp -rv * "/usr/bin/buildsystem/"
