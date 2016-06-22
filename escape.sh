# /bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

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

# Some package names contain characters that are special to the grep -E parser.
# This should escape those.
grep_escape()
{
  # It's difficult to escape ']' as a part of a character class.  It gets its
  # own substitution expression, as a result - the rest of the special
  # characters can all be replaced with a single class.
  echo "$@" \
    | sed -r \
      -e 's@([\\${}().*+[^])@\\\1@g' \
      -e 's@(\])@\\\1@g'
}

# sed probably differs from grep, so this interface exists in case sed escapes
# need to all be updated simultaneously in the future.
sed_escape()
{
  grep_escape "$@"
}
