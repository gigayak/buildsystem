#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version="4.02"
echo "$version" > "$YAK_WORKSPACE/version"
base_url="https://www.kernel.org/pub/linux/docs/man-pages"
current_url="$base_url/man-pages-$version.tar.gz"
archive_url="$base_url/Archive/man-pages-$version.tar.gz"
# TODO: Figure out how to get HTTPS CA certs installed so we don't
#   have to ignore certificate checks here.
if ! wget --no-check-certificate "$current_url" \
  && ! wget --no-check-certificate "$archive_url"
then
  echo "Failed to retrieve man-pages v$version." >&2
  echo "Tried:" >&2
  echo " - $current_url" >&2
  echo " - $archive_url" >&2
  exit 1
fi

tar -zxf *.tar.gz
