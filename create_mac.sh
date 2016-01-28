#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
# Default prefix of 52:54:00 is qemu's registered OUI.
add_flag prefix --default="52:54:00" "First 3 bytes of MAC address to generate."
parse_flags "$@"

random_mac()
{
  echo -n "$F_prefix"
  # Generate random remaining 3 bytes.
  dd \
    bs=1 \
    count=3 \
    if=/dev/random \
    2>/dev/null \
  | hexdump -v -e '/1 ":%02x"'
}

random_mac

# TODO: Check for collisions here.
