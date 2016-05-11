#!/bin/bash
set -Eeo pipefail

if (( "$#" < 1 ))
then
  echo "Usage: $(basename "$0") <subcmd> ..." >&2
  exit 1
fi

if [[ "$1" == "download" ]]
then
  echo "stubbed out apt-get download operation" > "$2.deb"
fi

exit 0
