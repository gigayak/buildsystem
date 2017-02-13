#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
add_flag --boolean distribution "Get name of distribution."
add_flag --boolean architecture "Get name of architecture."
add_flag --boolean libdir "Get name of library directory."
parse_flags "$@"
if (( "$F_distribution" + "$F_architecture" + "$F_libdir" > 1 )) \
  || (( "$F_distribution" + "$F_architecture" + "$F_libdir" <= 0 ))
then
  log_rote "use only one of --distribution, --architecture, or --libdir"
  exit 1
fi

if (( "$F_libdir" ))
then
  case "$(uname -m)" in
  x86_64|amd64)
    echo lib64
    exit 0
    ;;
  *)
    echo lib
    exit 0
    ;;
  esac
fi

if (( "$F_architecture" ))
then
  uname -m
  exit 0
fi


# This file appears to be a new "standard", albeit a very XKCD927-compliant
# one.  Probably has a million edge cases.
if [[ -e /etc/os-release ]]
then
  # Translates to:
  #   "archarm" for Arch Linux ARM
  #   ??? for Arch Linux x86
  #   "ubuntu" for Ubuntu
  #   ??? for Debian
  #   "yak" for Gigayak (this distribution)
  sed -n -r \
    -e 's@^\s*ID=(.*)$@\1@gp' \
    -e 's@^"@@' \
    -e 's@"$@@' \
    -e 's@\s*$@@' \
    /etc/os-release

# stage2 image should pretend to be natively compiling, as it is actually
# natively compiling despite its packages being labeled with a different
# distribution name (tools2).
elif [[ -e /tools ]]
then
  echo "yak"

# Oh, Redhat.  Redhat is often last to pick up on new standards, so Redhat
# is still stuck with checking for specific RPM names to determine distribution
# name.
elif \
  type rpm >/dev/null 2>&1 \
  && (
    rpm -q redhat-release >/dev/null 2>&1 \
    || rpm -q centos-release >/dev/null 2>&1 \
  )
then
  echo "redhat"

# TODO: Add logging of failed OS detection?
else
  echo "unknown"
fi
