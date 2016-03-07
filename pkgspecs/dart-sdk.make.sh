#!/bin/bash
set -Eeo pipefail

version=1.12.2
echo "$version" > "$YAK_WORKSPACE/version"
cd "$YAK_WORKSPACE"

# TODO: Break out depot_tools into its own package
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$YAK_WORKSPACE/depot_tools"
# Point depot_tools at python2.7 :[
# (This is an AWFUL way to do it!)
ln -sfv python2.7 /usr/bin/python
# The following would be better if I ever got it working:
#grep -lRE '^#!.*python' "$YAK_WORKSPACE/depot_tools" \
#  | xargs -I{} -- \
#    sed -r \
#      -e 's@^(#!.*python)(.*)$@\12.7\2@g' \
#      -i {}
#grep -LRE '^#!.*python' "$YAK_WORKSPACE/depot_tools" \
#  | xargs -I{} -- \
#    sed -r \
#      -e 's@python([^2])@python2.7\1@g' \
#      -e 's@python$@python2.7@g'

# Prevent "cd *-*/" from slurping up "depot_tools/"
mkdir dart-sdk
cd dart-sdk
gclient.py config https://github.com/dart-lang/sdk.git
# TODO: Maybe use an API here if GitHub has one that doesn't require special
# API keys?
archive="http://gsdview.appspot.com/dart-archive/channels/stable/release"
hash="$(curl "$archive/$version/VERSION")"
#hash="$(curl "https://github.com/dart-lang/sdk/releases/tag/$version" \
#  | sed -nre 's@^.*href="[^"]+/commit/([0-9a-f]+)".*$@\1@gp')"
# --jobs=1 is an attempt to rate limit some of the downloading, as
# this command was failing nondeterministically without much in the form
# of error messages...
gclient.py sync --revision="sdk@$hash" --jobs=1
cd sdk/

# TODO: Fix this issue upstream.  Addresses:
#   runtime/bin/builtin_natives.cc: In function
#      'void dart::bin::Builtin_Builtin_PrintString(Dart_NativeArguments)':
#   runtime/bin/builtin_natives.cc:95:35: error: ignoring return value of
#     'size_t fwrite(const void*, size_t, size_t, FILE*)', declared with
#     attribute warn_unused_result [-Werror=unused-result]
#      fwrite(chars, 1, length, stdout);
#                                      ^
#   cc1plus: all warnings being treated as errors
#
# This sed line prevents this warning from being treated as an error.
# It does not silence the warning, though, in the hopes that it will be
# fixed one day.
#sed \
#  -re 's@^(\s*)(-Wextra)(\s*\\)$@\1\2\3\n\1-Wno-error=unused-result\3@g' \
#  -i runtime/dart_bootstrap.host.mk
sed \
  -re 's@^(.*-Wnon-virtual-dtor.*)$@\1\n'"'"'-Wno-error=unused-result'"'"',@g' \
  -i runtime/bin/bin.gypi
sed \
  -re 's@^(.*-Wnon-virtual-dtor.*)$@\1\n"-Wno-error=unused-result",@g' \
  -i runtime/BUILD.gn

tools/build.py \
  --mode=release \
  --arch=x64 #ia32
