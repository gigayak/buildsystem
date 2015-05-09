#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/escape.sh"

echo "Regenerating all missing crypto files."
echo "These should never be checked in."
echo "However, setting up the trust for new keys can be a pain..."

key_strength="8192"
rsa_key_strength="$key_strength"
dsa_key_strength="$key_strength"
ssl_key_strength="$key_strength"
#storage_dir="/root/crypto"

types=(rsa dsa ssl)
rsa_keys=()
dsa_keys=()
ssl_keys=()

add_key()
{
  if (( "$#" < 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <key_user_name> <type> [<type> ...]" >&2
    echo >&2
    echo "<type> can be one of:" >&2
    echo "  RSA: SSH RSA key." >&2
    echo "  DSA: SSH DSA key." >&2
    echo "  SSL: CA-signed SSL key." >&2
    return 1
  fi

  key_name="$1"
  shift

  for type in "$@"
  do
    found=0
    for allowed_type in "${types[@]}"
    do
      if [[ "$allowed_type" == "$type" ]]
      then
        found=1
        break
      fi
    done
    if (( ! "$found" ))
    then
      echo "${FUNCNAME[0]}: unknown crypto key type '$type'" >&2
      return 1
    fi
    type_array="${type}_keys"
    eval "$type_array+=($(sq "$key_name"))"
  done
}

add_key godev rsa
add_key gitzebo rsa dsa

for algo in rsa dsa
do
  echo "Creating all SSH $algo keys."
  array_name="${algo}_keys[@]"
  algo_name="$(echo "$algo" | tr '[:lower:]' '[:upper:]')"
  strength_name="${algo}_key_strength"
  key_strength="${!strength_name}"
  for key_name in "${!array_name}"
  do
    #key_path="$storage_dir/${key_name}.ssh.${algo}"
    key_path="$("$DIR/get_crypto.sh" \
      --path_only \
      --private \
      --key_type="$algo" \
      --key_name="$key_name")"
    if [[ -e "$key_path" ]]
    then
      echo "$algo_name SSH key for ${key_name} already exists."
      continue
    fi
    echo "Generating $key_strength-bit $algo_name SSH key for '${key_name}'..."
    echo "8192 bit keys take ~10 minutes."
    time ssh-keygen \
      -t "$algo" \
      -C "john@jgilik.com" \
      -b "$key_strength" \
      -f "$key_path" \
      -N ''
  done
done

for key_name in "${ssl_keys[@]}"
do
  echo "$(basename "$0"): asked for SSL key for '$key_name' - not impl." >&2
  exit 1
done
