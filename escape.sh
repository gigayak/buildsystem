# /bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -z "$_ESCAPE_SH_INCLUDED" ]]
then
  return 0
fi
_ESCAPE_SH_INCLUDED=1

sq()
{
  echo "$@" \
    | sed \
      -r \
      -e "s@'@'\"'\"'@g" \
      -e "s@^@'@g" \
      -e "s@\$@'@g"
}
