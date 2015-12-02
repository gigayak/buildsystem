#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/repo.sh"

repodir="$_REPO_LOCAL_PATH"

# This script should create a whole bunch of stub packages pointing at the
# base Ubuntu chroot package, to ensure that packages installed in the chroot
# provided by debootstrap are resolved by the Gigayak dependency resolver.
if [[ ! -e "$repodir/base-ubuntu.tar.gz" ]]
then
  "$DIR/pkg.from_name.sh" --pkg_name=base-ubuntu
fi

while read -r pkg
do
  "$DIR/pkg.alias.sh" --target=base-ubuntu --alias="$pkg"
done < <(tar -zx \
  -f /var/www/html/tgzrepo/base-ubuntu.tar.gz \
  --to-stdout ./etc/base-ubuntu-packages)
