#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

cd phantomjs
cp -v bin/phantomjs /usr/bin/phantomjs
