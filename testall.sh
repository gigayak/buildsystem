#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

failures=0
while read -r test_name
do
  base_name="$(basename "$test_name")"
  if "$test_name" 2>/dev/null | grep 'FAIL:' | sed -re 's/^/'"$base_name"': /g'
  then
    failures="$(expr "$failures" + 1)"
  else
    echo "$base_name succeeded."
  fi
done < <(find "$DIR" -mindepth 1 -maxdepth 1 -iname '*_test.sh')

if (( "$failures" > 0 ))
then
  echo "Some tests failed."
  exit 1
fi

echo "All tests ran successfully!"
exit 0
