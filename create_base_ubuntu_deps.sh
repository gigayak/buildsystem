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
  echo "Creating stub package for '$pkg' aliased to 'base-ubuntu'" >&2
  echo "1.0" > "$repodir/$pkg.version"
  tar -z -c -T /dev/null -f "$repodir/$pkg.tar.gz"
  echo "base-ubuntu" > "$repodir/$pkg.dependencies"
  touch "$repodir/$pkg.done"
done < <(tar -zx \
  -f /var/www/html/tgzrepo/base-ubuntu.tar.gz \
  --to-stdout ./etc/base-ubuntu-packages)
