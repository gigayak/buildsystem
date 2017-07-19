#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=2.1.1
echo "$version" > "$YAK_WORKSPACE/version"

# We have to use git to clone from GitHub as the official release tarballs
# are stripped of the .git directories needed to initialize the qt submodules.
git clone git://github.com/ariya/phantomjs.git
cd phantomjs
git checkout "$version"
git submodule init
git submodule update
python build.py \
  --release \
  --confirm \
  --jobs=8
# Necessary to check for artifacts due to build.py exiting with return code
# 0 even on failure.
if [[ ! -f bin/phantomjs ]]
then
  echo "build failed, bin/phantomjs not found" >&2
  exit 1
fi
