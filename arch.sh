# /bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -z "$_ARCH_SH_INCLUDED" ]]
then
  return 0
fi
_ARCH_SH_INCLUDED=1

architecture()
{
  if (( "$#" != 0 ))
  then
    echo "Usage: ${FUNCNAME[0]}" >&2
    return 1
  fi

  # TODO: does this work across all platforms?!
  uname -m
}

centos_dir()
{
  if (( "$#" != 0 ))
  then
    echo "Usage: ${FUNCNAME[0]}" >&2
    return 1
  fi

  local arch="$(architecture)"
  if [[ "$arch" == i*86 ]]
  then
    echo "i386"
  else
    echo "$arch"
  fi
}

centos_compatible_architectures()
{
  if (( "$#" != 0 ))
  then
    echo "Usage: ${FUNCNAME[0]}" >&2
    return 1
  fi

  local arch="$(architecture)"
  if [[ "$arch" == i*86 ]]
  then
    echo "i386 i486 i586 i686"
  else
    echo "$arch"
  fi
}
