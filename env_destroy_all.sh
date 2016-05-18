#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/escape.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"

add_flag --boolean active "even destroy active LXC container roots"
add_flag --boolean persistent "even destroy persistent chroots"
parse_flags "$@"

unmount_chroot()
{
  chroot="$1"
  escaped="$(echo "$chroot" | sed -re 's@\.@\\.@g')"
  while read -r mnt
  do
    umount "$mnt"
  done < <(findmnt -r \
    | awk '{print $1}' \
    | sed -nre 's@^('"$escaped"'/.*)$@\1@gp')
}

active_lxc_roots=()
active_lxc_names=()

# Clean up LXC containers.
while read -r n
do
  log_rote "finding root for LXC container $n"
  t="$(lxc-info --name="${n}" -c lxc.rootfs \
    | sed -nre 's@^\S+\s*=\s*(\S+)$@\1@gp')"

  log_rote "checking if LXC container $n is up"
  if [[ "$(lxc-info -n "$n" | grep -e '^State:' | awk '{print $2}')" \
    == "RUNNING" ]]
  then
    if (( "${F_active}" ))
    then
      log_rote "destroying active container $n"
      "$(DIR)/destroy_container.sh" --name="$n"
      continue
    else
      log_rote "ignoring active container $n"
      active_lxc_roots+=("$t")
      active_lxc_names+=("$n")
      continue
    fi
  fi

  log_rote "destroying LXC container $n"
  unmount_chroot "$t"
  lxc-destroy --name="$n"
done < <(lxc-ls -1)

# Clean up chroot directories.
for temp_root in "${_TEMP_ROOTS[@]}"
do
  if [[ ! -e "$temp_root" ]]
  then
    continue
  fi

  to_remove="$temp_root/roots_to_remove"
  find "$temp_root" -mindepth 1 -maxdepth 1 -iname 'tmp.*' > "$to_remove"
  if (( "$F_persistent" ))
  then
    find "$temp_root" -mindepth 1 -maxdepth 1 -iname 'chroot.*' >> "$to_remove"
  fi

  log_rote "cleaning temp root '$temp_root'"
  while read -r t
  do
    for root in "${active_lxc_roots[@]}"
    do
      if [[ "$root" == "$t" ]]
      then
        log_rote "ignoring root $t owned by active LXC session"
        continue 2
      fi
    done
    log_rote "destroying temporary chroot $t..."
    unmount_chroot "$t"
    rm -rf "$t"
  done < "$to_remove"

  rm "$to_remove"
done

# Clean up IPs.
lease_file=/tmp/ip.gigayak.allocations
lease_file_new="$lease_file.new"
rm -fv "$lease_file_new"
touch "$lease_file_new"
localstorage="$("$(DIR)/find_localstorage.sh")"
hosts_file="$localstorage/dns/dns/hosts.autogen"
hosts_file_new="$hosts_file.new"
rm -fv "$hosts_file_new"
touch "$hosts_file_new"
while read -r lease
do
  ip="$(echo "$lease" | awk '{print $1}')"
  owner_spec="$(echo "$lease" | awk '{print $2}')"
  owner_type="$(echo "$owner_spec" | sed -nre 's@^([^:]+):.*$@\1@gp')"
  if [[ -z "$owner_type" ]]
  then
    log_error "unrecognized IP owner type for IP owner '$owner_spec'" 
    continue
  fi
  owner="$(echo "$owner_spec" | sed -nre 's@^[^:]+:(.*)$@\1@gp')"
  if [[ -z "$owner" ]]
  then
    log_error "no owner specified for IP $ip by owner spec '$owner_spec'"
    continue
  fi

  if [[ "$owner_type" == "lxc" ]]
  then
    for container in "${active_lxc_names[@]}"
    do
      if [[ "$container" == "$owner" ]]
      then
        retval=0
        grep -E "^$(grep_escape "$ip")\s+" "$hosts_file" >> "$hosts_file_new" \
          || retval=$?
        if (( "$retval" ))
        then
          log_fatal "could not find hosts entry for container '$owner'"
        fi
        retval=0
        grep -E "^$(grep_escape "$ip")\s+" "$lease_file" >> "$lease_file_new" \
          || retval=$?
        if (( "$retval" ))
        then
          log_fatal "could not find lease entry for container '$owner'"
        fi
        break
      fi
    done
  elif [[ "$owner_type" == "chroot" ]]
  then
    echo -n ""
  else
    log_error "unknown owner type '$owner_type' - what the heck?"
  fi
done < "$lease_file"
mv -vf "$hosts_file_new" "$hosts_file"
mv -vf "$lease_file_new" "$lease_file"
"$(DIR)/reload_dnsmasq.sh"
