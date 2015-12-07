#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"
source "$DIR/flag.sh"
source "$DIR/mkroot.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags

bootstrap="$DIR/pkgspecs/$F_pkg_name.bootstrap.sh"
if [[ ! -e "$bootstrap" ]]
then
  echo "$(basename "$0"): bootstrap script '$bootstrap' not found" >&2
  exit 1
fi

make_temp_dir tmprepo
"$bootstrap" > "$tmprepo/$F_pkg_name.tar.gz"
echo 1.0 > "$tmprepo/$F_pkg_name.version"
if [[ -e "$DIR/pkgspecs/$F_pkg_name.deps.sh" ]]
then
  "$DIR/pkgspecs/$F_pkg_name.deps.sh" > "$tmprepo/$F_pkg_name.dependencies"
else
  touch "$tmprepo/$F_pkg_name.dependencies"
fi
touch "$tmprepo/$F_pkg_name.done"

for n in tar.gz version dependencies done
do
  mv -vf "$tmprepo/$F_pkg_name.$n" "/var/www/html/tgzrepo/$F_pkg_name.$n"
done
