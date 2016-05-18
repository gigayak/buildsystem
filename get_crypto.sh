#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# Dumb script used to get crypto keys from the cryptography store created by
# create_crypto.sh.
#
# For something this sensitive, it has a lot of path traversal vulnerabilities.
#
# TODO: Port to something more sane ASAP.

# TODO: This script will NOT function inside of qemu VMs, as it relies on a
# local repository for crypto credentials.  Should make this a client/server
# thing.


source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"

add_flag --boolean path_only "If set, returns just the expected key path."
add_flag --boolean private "Fetch the private key.  Mutex /w --public."
add_flag --boolean public "Fetch the public key.  Mutex /w --private."
add_flag --required key_name "Name of key to fetch."
add_flag --required key_type "Type of key to fetch (rsa, dsa, ssl)."

parse_flags "$@"

storage_dir="/root/crypto"
key_types=(rsa dsa ssl)

if (( ( ! "${F_private}" && ! "${F_public}" ) || \
  ( "${F_private}" && "${F_public}" ) ))
then
  log_rote "need exactly one of --public or --private"
  exit 1
fi

found=0
for key_type in "${key_types[@]}"
do
  if [[ "$F_key_type" != "$key_type" ]]
  then
    continue
  fi
  found=1
done
if (( ! "$found" ))
then
  log_rote "unknown key type '$F_key_type'"
  log_rote "must be one of: ${key_types[@]}"
  exit 1
fi

if [[ ! -e "$storage_dir" ]]
then
  mkdir -p "$storage_dir"
fi

# Determine where the key should be.
if [[ "${F_key_type}" == "rsa" || "${F_key_type}" == "dsa" ]]
then
  key_path="$storage_dir/$F_key_name.ssh.$F_key_type"
  if (( "$F_public" ))
  then
    key_path="$key_path.pub"
  fi
fi

if [[ "${F_key_type}" == "ssl" ]]
then
  log_rote "SSL keys not yet supported."
  exit 1
fi

# Short circuit if just the path is desired.
if (( "${F_path_only}" ))
then
  echo "$key_path"
  exit 0
fi

# Dump the key.
# TODO: ACL checks of some sort :X  This is a huge vulnerability :(
if [[ ! -e "$key_path" ]]
then
  log_rote "key does not exist at '$key_path'"
  exit 1
fi
cat "$key_path"
