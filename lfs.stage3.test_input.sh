#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"

failures=0

arch=i686
while read -r tarball
do
  # Derive other metadata filenames from tarball name.
  dirname="$(dirname "$tarball")"
  pkgname="$(basename "$tarball" .tar.gz)"
  dependencies="${dirname}/${pkgname}.dependencies"

  # We're planning on making a mess - centralize it...
  make_temp_dir work

  # Test: scan dependencies for ${arch}-tools references.
  # Any references to these packages indicates dependency problems, as the
  # cross-compiled compilation toolchain should not be used for production
  # purposes due to the high possibility of bugs when the cross-compiled
  # toolchain is used for *anything* other than its primary use case of
  # building a natively-compiled toolcahin - however, dependency references 
  # would cause them to be installed on production systems.
  depcheck="$work/${pkgname}.depcheck"
  if grep -E '^[a-zA-Z0-9]+-tools2?-' "$dependencies" > "$depcheck" 2>&1
  then
    failures="$(expr "$failures" + 1)"
    echo "FAIL: ${pkgname} tools dependencies check"
  else
    echo "PASS: ${pkgname} tools dependencies check"
  fi

  # Extract tarball so we can play with it.
  mkdir "$work/tar_contents"
  tar -C "$work/tar_contents" -xf "$tarball"

  # Test: scan contents for /tools/ references.
  # Any references to /tools/ at this point indicates linker/dependency
  # problems, as ${arch}-tools / ${arch}-tools2 packages will NOT be installed
  # alongside ${arch}-yak packages in production.
  found_tools=0
  while read -r filename
  do
    strip "$filename" >/dev/null 2>&1 || true

    if strings "$filename" | grep "/tools/${arch}" >/dev/null 2>&1
    then
      found_tools=1
      echo "${pkgname} contains /tools/${arch}/ reference in $filename" >&2
    fi
  done < <(find "$work/tar_contents" -type f)
  if (( "$found_tools" ))
  then
    echo "FAIL: ${pkgname} tools references within contents check"
  else
    echo "PASS: ${pkgname} tools references within contents check"
  fi

  # Clean up our mess.
  "$DIR/recursive_umount.sh" "$work"
  rm -rf "$work"
  unregister_temp_file "$work"
done < <(find /var/www/html/tgzrepo -iname "$arch"'-yak-*.tar.gz')

if (( "$failures" <= 0 ))
then
  exit 0
fi
echo "$(basename "$0"): found problems with $failures stage3 (yak) packages" >&2
exit 1
