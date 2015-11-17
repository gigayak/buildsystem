#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
source "$DIR/cleanup.sh"
add_flag --required pkg_name "Name of the package to convert."
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to output packages."
parse_flags

outdir="${F_repo_path}"
make_temp_dir workdir

convert_apt_package()
{
  local pkg="$1"
  if [[ -z "$pkg" ]]
  then
    echo "${FUNCNAME[0]}: no package name provided" >&2
    return 1
  fi
  echo "${FUNCNAME[0]}: attempting to convert Apt package '$pkg' to TGZ" >&2

  if [[ -e "$outdir/$pkg.done" ]]
  then
    echo "${FUNCNAME[0]}: package '$pkg' already exists in '$outdir'" >&2
    echo "${FUNCNAME[0]}: skipping conversion of package '$pkg'" >&2
    return 0
  fi

  local WORKDIR="$workdir/$pkg"
  if [[ -e "$WORKDIR" ]]
  then
    if [[ -e "$WORKDIR/$pkg.done" ]]
    then
      echo "${FUNCNAME[0]}: package '$pkg' already processed; skipping" >&2
    else
      echo "${FUNCNAME[0]}: package '$pkg' processing elsewhere; skipping" >&2
    fi
    return 0
  fi
  mkdir -pv "$WORKDIR"

  cd "$WORKDIR"
  apt-get download "$pkg"
  local deb="$(find "$WORKDIR" -iname "${pkg}_*.deb")"
  if [[ -z "$deb" ]]
  then
    echo "${FUNCNAME[0]}: failed to find .deb we just downloaded" >&2
    return 1
  fi

  # Make note of the version.
  dpkg -I "$deb" \
    | sed -nre 's@^ Version: (.*)$@\1@gp' \
    > "$pkg.version"

  # Resolve all dependencies.
  dpkg -I "$deb" \
    | sed -nre 's@^ Depends: (.*)$@\1@gp' \
    | sed -re 's@, @\n@g' \
    | sed -re 's@ \|.*$@@g' \
    | sed -re 's@ \([^)]+\)@@g' \
    > "$pkg.dependencies"

  # Process all requirements.
  local dep
  while read -r dep
  do
    convert_apt_package "$dep"
    cd "$WORKDIR"
  done < "$pkg.dependencies"

  # Finalize conversion.
  echo "Converting '$pkg' to TGZ"
  mkdir "$WORKDIR/out"
  cd "$WORKDIR/out"
  dpkg --extract "$deb" "$WORKDIR/out"
  tar -czf "$WORKDIR/$pkg.tar.gz" .
  cd "$WORKDIR"
  touch "$pkg.done"

  # Publish TGZ and support files.
  local n
  for n in dependencies version tar.gz done
  do
    cp "$pkg.$n" "$outdir/"
  done
}

convert_apt_package "${F_pkg_name}"
