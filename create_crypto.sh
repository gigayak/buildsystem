#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/config.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"

echo "$(basename "$0"): Regenerating all missing crypto files."
echo "$(basename "$0"): These should never be checked in."

# TODO: refactor this into multiple scripts
# key_strength applies to SSH keys
key_strength="8192"
rsa_key_strength="$key_strength"
ssl_key_strength="$key_strength"
# DSA keys are apparently limited by standards to 1024 bits.
# Otherwise, ssh-keygen yields "DSA keys must be 1024 bits."
# TODO: Remove DSA keys entirely and see what breaks?
dsa_key_strength="1024"
domain="$YAK_DOMAIN"

ssh_key()
{
  algo="$1"
  key_name="$2"
  if [[ -z "$algo" || -z "$key_name" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <algorithm> <key name>" >&2
    return 1
  fi

  algo_name="$(echo "$algo" | tr '[:lower:]' '[:upper:]')"
  strength_name="${algo}_key_strength"
  key_strength="${!strength_name}"
  key_path="$("$(DIR)/get_crypto.sh" \
    --path_only \
    --private \
    --key_type="$algo" \
    --key_name="$key_name")"
  if [[ -e "$key_path" ]]
  then
    echo "${FUNCNAME[0]}: $algo_name SSH key for ${key_name} exists" >&2
    return 0
  fi
  echo "${FUNCNAME[0]}: generating $key_strength-bit $algo_name" \
    "SSH key for '${key_name}'" >&2
  echo "${FUNCNAME[0]}: 8192 bit keys take ~10 minutes." >&2
  time ssh-keygen \
    -t "$algo" \
    -C "${key_name}@$domain" \
    -b "$key_strength" \
    -f "$key_path" \
    -N ''
}
ssh_rsa_key()
{
  ssh_key rsa "$@"
}
ssh_dsa_key()
{
  ssh_key dsa "$@"
}

# create a named temp root from _TEMP_ROOTS
# check for necessary bind mounts to CA configuration
# chroot and create keys
# move keys out
temp_root=""
for root in "${_TEMP_ROOTS[@]}"
do
  if [[ -e "$root" ]]
  then
    temp_root="$root"
    break
  fi
done
if [[ -z "$temp_root" ]]
then
  echo "$(basename "$0"): unable to find writable temp root" >&2
  exit 1
fi
root="$temp_root/chroot.certificate_authority"
if [[ ! -e "$root" ]]
then
  mkdir -pv "$root"{,/proc,/sys,/opt/ca}
  "$(DIR)/install_pkg.sh" \
    --install_root="$root" \
    --pkg_name="env-ca"
fi
for mnt in /proc /sys /dev
do
  if [[ ! -e "$root$mnt" ]]
  then
    mkdir -p "$root$mnt"
  fi
  if ! mountpoint -q -- "$root$mnt"
  then
    mount --bind "$mnt" "$root$mnt"
  fi
done

ca_root="$root/opt/ca"
localstorage="$("$(DIR)/find_localstorage.sh")"
if [[ ! -e "$ca_root" ]]
then
  mkdir -p "$ca_root"
fi
if ! mountpoint -q -- "$ca_root"
then
  mount --bind "$localstorage/certificate-authority/ca" "$ca_root"
fi
if [[ ! -e "$ca_root/.initialized" ]]
then
  chroot "$root" ca_init "$domain"
fi

ssl_server_cert()
{
  key_name="$1"
  shift
  if [[ -z "$key_name" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <key_name> [extra domain name] ..." >&2
    return 1
  fi
  key_path="$ca_root/keys/$key_name.key"
  crt_path="$ca_root/certificates/$key_name.crt"
  if [[ -e "$key_path" && -e "$crt_path" ]]
  then
    echo "${FUNCNAME[0]}: found SSL cert $(sq "$key_name"), skipping" >&2
    return 0
  fi
  echo "${FUNCNAME[0]}: creating SSL certs for $(sq "$key_name")" >&2
  for san in "$@"
  do
    echo "${FUNCNAME[0]}: adding alternate name $(sq "$san")" >&2
  done
  chroot "$root" ca_generate_certificate "$key_name" "$domain" "$@"
  tgt_path="$localstorage/$key_name/ssl"
  if [[ ! -e "$tgt_path" ]]
  then
    mkdir -pv "$tgt_path"
  fi
  cp -vf \
    "$ca_root/keys/$key_name.key" \
    "$tgt_path/$key_name.key"
  cp -vf \
    "$ca_root/certificates/$key_name.crt" \
    "$tgt_path/$key_name.crt"
}

ssl_client_cert()
{
  if (( "$#" != "3" ))
  then
    echo "Usage: ${FUNCNAME[0]} <username> <fqdn> <client name>" >&2
    return
  fi
  username="$1"
  fqdn="$2"
  client_name="$3"
  key_path="$ca_root/keys/client.$username@$fqdn.key"
  crt_path="$ca_root/certificates/client.$username@$fqdn.crt"
  if [[ -e "$key_path" && -e "$crt_path" ]]
  then
    echo "${FUNCNAME[0]}: found SSL cert $username@$fqdn, skipping" >&2
    return 0
  fi
  echo -e "no cert found:\nkey_path: $key_path\ncrt_path: $crt_path"
  chroot "$root" ca_generate_client_certificate \
    "$username" "$fqdn" "$domain" "$client_name"
}


ssh_rsa_key godev
ssh_rsa_key gitzebo
ssh_dsa_key gitzebo
ssl_server_cert gitzebo "git" "git.$domain"
ssl_server_cert proxy "*.$domain"
ssl_server_cert repo
ssl_server_cert www
# TODO: Break out client certificate names into a configuration file.
ssl_client_cert jgilik "oven.home.$domain" "John Gilik / Desktop"
ssl_client_cert jgilik "hp11.home.$domain" "John Gilik / HP11 Chromebook"
ssl_client_cert system "dl380.home.$domain" "System / DL380"
ssl_client_cert system "stage2.automation.$domain" "System / stage2 build"
ssl_client_cert system "stage3.automation.$domain" "System / stage3 build"

echo "$(basename "$0"): successfully created all keys and certs" >&2
