#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/../escape.sh"
source "$(DIR)/../log.sh"

download()
{
  wget "$*"
}

download_one_of()
{
  urls=("$@")
  for url in "${urls[@]}"
  do
    if download "$url"
    then
      return 0
    fi
  done
  return 1
}

download_sourceforge()
{
  local path
  path="$*"
  if [[ -z "$path" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <sourceforge path>" >&2
    echo >&2
    echo "Example: ${FUNCNAME[0]} tcl/Tcl/8.6.4/tcl8.6.4-src.tar.gz" >&2
    echo "(gets TCL 8.6.4)" >&2
    return 1
  fi

  # Is a normal download possible?  If so, avoid extra GET requests from
  # mirror polling.
  local url
  url="http://downloads.sourceforge.net/project/$path"
  if wget --method=HEAD --tries=1 -O- "$url"
  then
    log_rote "Sourceforge appears to be in normal mode, downloading directly"
    log_rote "downloading from $(sq "$url")"
    wget "$url" || return "$?"
    return 0
  fi

  # Disaster recovery mode doesn't let us hit the URL directly :(
  # Instead, we can look up a mirror manually by using mirrors.js.
  log_rote "Sourceforge appears to be in disaster recovery mode"
  log_rote "polling mirrors manually"
  local urls
  urls=()
  while read -r mirror
  do
    url="http://${mirror}.dl.sourceforge.net/project/${path}"
    urls+=("$url")
  done < <(wget "http://sourceforge.net/js/mirrors.js" -O- 2>/dev/null \
    | sed -nre "s@^.*'abbr': '([^']*)'.*\$@\1@p" \
    | shuf)
  # | shuf ensures that we don't just hammer the mirror at the very top of
  # mirrors.js for every build.  Instead, we try mirrors in a random order.

  if download_one_of "${urls[@]}"
  then
    return 0
  fi
  log_error "no mirrors had the file $(sq "$path")"
  return 1
}
