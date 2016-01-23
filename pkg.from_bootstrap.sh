#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"
source "$DIR/flag.sh"
source "$DIR/repo.sh"
source "$DIR/mkroot.sh"
add_flag --required pkg_name "Name of the package to build."
add_flag --default="" target_architecture \
  "Name of architecture to build for.  Defaults to host architecture."
add_flag --default="" target_distribution \
  "Name of distribution to build for.  Defaults to host distribution."
add_flag --boolean check_only "Whether to only check if build is possible."
parse_flags

arch="$F_target_architecture"
if [[ -z "$arch" ]]
then
  arch="$("$DIR/os_info.sh" --architecture)"
fi
distro="$F_target_distribution"
if [[ -z "$distro" ]]
then
  distro="$("$DIR/os_info.sh" --distribution)"
fi

found=0
bootstrap_files=()
bootstrap_files+=("$DIR/pkgspecs/${F_pkg_name}.bootstrap.sh")
bootstrap_files+=("$DIR/pkgspecs/${arch}-${distro}-${F_pkg_name}.bootstrap.sh")
for bootstrap in "${bootstrap_files[@]}"
do
  if [[ -e "$bootstrap" ]]
  then
    found=1
    break
  fi
done
if (( ! "$found" ))
then
  echo "$(basename "$0"): bootstrap script not found" >&2
  for bootstrap in "${bootstrap_files[@]}"
  do
    echo "$(basename "$0"): consider creating '$bootstrap'" >&2
  done
  exit 1
fi
if (( "$F_check_only" ))
then
  echo "$(basename "$0"): can build '$F_pkg_name' via bootstrap" >&2
  exit 0
fi

dep="$(qualify_dep "$arch" "$distro" "$F_pkg_name")"

make_temp_dir tmprepo
"$bootstrap" > "$tmprepo/${dep}.tar.gz"
echo 1.0 > "$tmprepo/${dep}.version"
depscript="$(dirname "$bootstrap")"
depscript="${depscript}$(basename "$bootstrap" .bootstrap.sh)"
depscript="${depscript}.deps.sh"
if [[ -e "$depscript" ]]
then
  "$depscript" > "$tmprepo/${dep}.dependencies"
else
  touch "$tmprepo/${dep}.dependencies"
fi
touch "$tmprepo/${dep}.done"

for n in tar.gz version dependencies done
do
  mv -vf "$tmprepo/${dep}.$n" "/var/www/html/tgzrepo/${dep}.$n"
done
