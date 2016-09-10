#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/log.sh"

root="$(select_temp_root)/chroot.vm"
if [[ -e "$root" ]]
then
  log_rote "Destroying VM root $(sq "$root")"
  recursive_umount "$root"
  rm -rf "$root"
fi

log_rote "Populating VM root $(sq "$root")"
mkdir "$root"
for d in dev proc sys
do
  mkdir "$root/$d"
  mount --bind "/$d" "$root/$d"
done
for p in qemu openssh parted rsync
do
"$(DIR)/install_pkg.sh" \
  --install_root="$root" \
  --pkg_name="$p"
done
cp "/var/www/html/tgzrepo/stage3.raw" "$root/root/stage3.raw"
log_rote "VM root $(sq "$root") available for chroot."
