#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"
source "$DIR/escape.sh"
source "$DIR/flag.sh"
add_usage_note <<EOF
This script finds dependencies for a given set of paths using LDD lookups.
It's a total kludge, but I've been using it for sorting out i686-tools-
dependencies to reduce the size of the initrd image, which can't be too
large.
EOF
add_flag --required pkg_name "Name of package to inspect"
parse_flags "$@"

pkg="$F_pkg_name"

make_temp_dir scratch
echo "$(basename "$0"): extracting $pkg.tar.gz" >&2
root="$scratch/root"
mkdir -p "$root"
cd "$root"
tar -zxf "/var/www/html/tgzrepo/$pkg.tar.gz"

executables="$scratch/executables"
find . -type f -perm /111 > "$executables"

echo "$(basename "$0"): enumerating all desired libraries" >&2
libraries="$scratch/libraries"
while read -r executable
do
  ext="$(echo "$executable" | sed -nre 's@^.*\.([^.]+)$@\1@gp')"
  # Only dynamic libraries and dynamic executable binaries can be
  # inspected using this gnarly ldd hack.
  if [[ "$ext" == "la" ]]
  then
    continue
  fi
  ldd "$executable" 2>/dev/null \
    | awk '{print $1}' \
    | sed -re 's@^.*/([^/]+)$@\1@g' \
  >> "$libraries"
done < "$executables"

desired_libs=()
add_lib()
{
  if [[ -z "$1" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <library name>" >&2
    return 1
  fi
  desired_libs+=("$1")
}
remove_lib()
{
  if [[ -z "$1" ]]
  then
    echo "Usage: ${FUNCNAME[0]} <library name>" >&2
    return 1
  fi
  desired_libs_copy=("${desired_libs[@]}")
  desired_libs=()
  for lib in "${desired_libs_copy[@]}"
  do
    if [[ "$lib" != "$1" ]]
    then
      desired_libs+=("$lib")
    fi
  done
}
while read -r lib
do
  # linux-gate.so.? is a virtual library used to interface to the kernel:
  #   http://stackoverflow.com/a/19982078
  base_lib="$(echo "$lib" | sed -nre 's@^([^.]+)(\..*)?$@\1@gp')"
  if [[ "$base_lib" == "linux-gate" ]]
  then
    continue
  fi
  add_lib "$lib"
done < <(sort "$libraries" | uniq)

# These packages are large and take a LONG time to read.
# They also contain no libraries to discover.
ignore_packages=()
ignore_packages+=("i686-tools-linux")
ignore_packages+=("i686-tools-initrd")

while read -r pkg
do
  pkg_name="$(basename "$pkg" .tar.gz)"
  ignore=0
  for ignored_pkg in "${ignore_packages[@]}"
  do
    if [[ "$pkg_name" == "$ignored_pkg" ]]
    then
      ignore=1
    fi
  done
  if (( "$ignore" ))
  then
    continue
  fi
  # This appears here rather than at the beginning of the loop to
  # ensure we don't output log spam for ignored packages.
  echo "$(basename "$0"): looking for libraries in $pkg_name" >&2

  manifest=/tmp/pkgmanifest
  tar -tzvf "$pkg" \
    > "$manifest"

  for lib in "${desired_libs[@]}"
  do
    lib_escaped="$(echo "$lib" \
      | sed \
        -r \
        -e 's@\.@\\.@g' \
    )"
    grep -E "/$lib_escaped"'(\s+.*)?$' "$manifest" \
      > /dev/null \
      || continue
    echo "$(basename "$pkg" .tar.gz) satisfies $lib"
    remove_lib "$lib"
  done
done < <(find /var/www/html/tgzrepo -iname 'i686-tools-*.tar.gz')
echo "$(basename "$0"): wrapping up" >&2

status=0
for lib in "${desired_libs[@]}"
do
  echo "NOTHING satisfies $lib"
  echo "$(basename "$0"): could not find $(sq "$lib")" >&2
  status=1
done

exit "$status"
