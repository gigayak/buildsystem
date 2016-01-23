#!/bin/bash
set -Eeo pipefail

cd /root
paths=()
paths+=("https://git.jgilik.com/certificate-authority.git")
paths+=("https://github.com/gigayak/certificate-authority.git")
found=0
for path in "${paths[@]}"
do
  if curl \
    --head \
    --fail \
    "$path" \
    >/dev/null
  then
    echo "Building from URL $path" >&2
    found=1
    break
  fi
  echo "Not considering URL $path" >&2
done
if (( ! "$found" ))
then
  echo "Failed to find valid URL for certificate-authority." >&2
  exit 1
fi
git clone "$path"

