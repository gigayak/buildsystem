#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/config.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/log.sh"
source "$(DIR)/repo.sh"

log_rote "Regenerating all missing crypto files."
log_rote "These should never be checked in."

# TODO: refactor this into multiple scripts
# key_strength applies to SSH keys
# Dropbear and GnuPG have 4096-bit maximums, so we use 4096 bits.
key_strength="4096"
rsa_key_strength="$key_strength"
ssl_key_strength="$key_strength"
# DSA keys are apparently limited by standards to 1024 bits.
# Otherwise, ssh-keygen yields "DSA keys must be 1024 bits."
# TODO: Remove DSA keys entirely and see what breaks?
dsa_key_strength="1024"
domain="$(get_config DOMAIN)"

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
    log_rote "$algo_name SSH key for ${key_name} exists"
    return 0
  fi
  log_rote "generating $key_strength-bit $algo_name SSH key for '${key_name}'"
  log_rote "8192 bit keys take ~10 minutes."
  if type ssh-keygen >/dev/null 2>&1
  then
    log "using ssh-keygen binary for key generation"
    time ssh-keygen \
      -t "$algo" \
      -C "${key_name}@$domain" \
      -b "$key_strength" \
      -f "$key_path" \
      -N ''
  elif type dropbearkey >/dev/null 2>&1
  then
    # Dropbear uses a different name for DSA - go figure.
    if [[ "$algo" == "dsa" ]]
    then
      algo=dss
    fi
    time dropbearkey \
      -t "$algo" \
      -f "$key_path" \
      -s "$key_strength"
  else
    log_error "unable to find an SSH key generation program"
    return 1
  fi
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
  log_rote "unable to find writable temp root"
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
if [[ ! -e "$ca_root" ]]
then
  mkdir -p "$ca_root"
fi
localstorage="$("$(DIR)/find_localstorage.sh")"
if [[ ! -e "$localstorage/certificate-authority/ca" ]]
then
  mkdir -p "$localstorage/certificate-authority/ca"
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
    log_rote "found SSL cert $(sq "$key_name"), skipping"
    return 0
  fi
  log_rote "creating SSL certs for $(sq "$key_name")"
  for san in "$@"
  do
    log_rote "adding alternate name $(sq "$san")"
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
    log_rote "found SSL cert $username@$fqdn, skipping"
    return 0
  fi
  log_error "no cert found"
  log_error " - key_path: $key_path"
  log_error " - crt_path: $crt_path"
  chroot "$root" ca_generate_client_certificate \
    "$username" "$fqdn" "$domain" "$client_name"
}

maybe_rebuild_cert_package()
{
  add_flag --required "certificate_source" "File in \$ca_root to package."
  add_flag --required "pkg_name" "Package cert should be in."
  add_flag --required "certificate_target" "Name of file in package."
  parse_flags "$@"

  target_md5="$(md5sum "$ca_root/${F_certificate_source}" | awk '{print $1}')"
  rm -rf "$root/tmp"
  mkdir -p "$root/tmp"
  #repo_list > "$root/tmp/repo.list"
  ls -1 /var/www/html/tgzrepo > "$root/tmp/repo.list"
  while read -r pkg
  do
    pkg_spec="$(basename "$pkg" .done)"
    tarball_name="${pkg_spec}.tar.gz"
    mkdir -p "$root/tmp"
    tarball_path="$root/tmp/$tarball_name"
    repo_get "$tarball_name" > "$tarball_path"
    while read -r cert_name
    do
      candidate_md5="$(tar -zxf "$tarball_path" --to-stdout "$cert_name" \
        | md5sum - \
        | awk '{print $1}')"
      if [[ "$candidate_md5" != "$target_md5" ]]
      then
        log_rote "$pkg_spec must be rebuilt"
        build_from_dependency "$pkg_spec"
      fi
    done < <(tar -tzf "$tarball_path" | grep -E "${F_certificate_target}\$")
  done < <(grep -E ":${F_pkg_name}.done\$" "$root/tmp/repo.list")
}

maybe_rebuild_internal_ca_certs()
{
  maybe_rebuild_cert_package \
    --certificate_source="authority/ca.crt" \
    --certificate_target="gigayak.pem" \
    --pkg_name="internal-ca-certificates"
}

maybe_rebuild_stage2_client_certs()
{
  maybe_rebuild_cert_package \
    --certificate_source="certificates/client.system@stage2.automation.${domain}.crt" \
    --certificate_target="client.crt" \
    --pkg_name="stage2-certificate"
}

maybe_rebuild_stage3_client_certs()
{
  maybe_rebuild_cert_package \
    --certificate_source="certificates/client.system@stage3.automation.${domain}.crt" \
    --certificate_target="client.crt" \
    --pkg_name="stage3-certificate"
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
maybe_rebuild_internal_ca_certs
maybe_rebuild_stage2_client_certs
maybe_rebuild_stage3_client_certs

log_rote "successfully created all keys and certs"
