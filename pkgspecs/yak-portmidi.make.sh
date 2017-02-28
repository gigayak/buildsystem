#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=217
echo "$version" > version
source "$YAK_BUILDTOOLS/download.sh"
download_sourceforge "portmedia/portmidi/$version/portmidi-src-${version}.zip"
unzip *.zip
cd */

# HACK SCALE: SOMEWHAT DIRTY, PLEASE DUST
#
# This removes references to Java, so that I don't have to tackle building the
# OpenJDK yet (which is... non-trivial at best).
#
# Hack guided by: https://github.com/aoeu/portmidi/commits/master
#
# I decided to avoid skipping reading the prefs.xml file unlike aoeu, since
# there's a possibility that someone runs pmdefaults on another platform or
# compiles it separately.  No need to kill the code to read the generated
# prefs - if it's there, it will get used.
#
# Additionally, chose to use sed instead of maintaining a forked repo, since
# these sed expressions will hopefully apply to future versions of portmidi.
rm -rf pm_java
sed -r -e 's@(INSTALL\(.*) pmjni(.*)$@\1\2@g' -i pm_common/CMakeLists.txt
while read -r path
do
  sed -r \
    -e '/JAVA/Id' \
    -e '/JNI/Id' \
    -i "$path"
done < <(find . -name 'CMakeLists.txt')

cmake -D CMAKE_INSTALL_PREFIX=/usr .
make
