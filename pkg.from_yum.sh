#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/log.sh"
add_flag --required pkg_name "Name of the package to convert."
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to output packages."
parse_flags "$@"

outdir="${F_repo_path}"
make_temp_dir workdir

convert_yum_package()
{
  local pkg="$1"
  if [[ -z "$pkg" ]]
  then
    log_rote "no package name provided"
    return 1
  fi

  if [[ -e "$outdir/$pkg.done" ]]
  then
    log_rote "package '$pkg' already exists in '$outdir'"
    log_rote "skipping conversion of package '$pkg'"
    return 0
  fi

  local WORKDIR="$workdir/$pkg"
  if [[ -e "$WORKDIR" ]]
  then
    if [[ -e "$WORKDIR/$pkg.done" ]]
    then
      log_rote "package '$pkg' already processed; skipping"
    else
      log_rote "package '$pkg' processing elsewhere; skipping"
    fi
    return 0
  fi
  mkdir -pv "$WORKDIR"

  cd "$WORKDIR"
  yumdownloader "$pkg"
  local rpm="$(find "$WORKDIR" -iname "$pkg-*.rpm")"
  if [[ -z "$rpm" ]]
  then
    log_rote "failed to find RPM we just downloaded"
    return 1
  fi

  # Make note of the version.
  rpm \
    -qp "$rpm" \
    --queryformat='%{VERSION}-%{RELEASE}' \
    | sed -re 's@\.el[0-9]+.*$@@g' \
    > "$pkg.version"

  # Resolve all requirements.
  rpm -qp "$rpm" --requires > "$pkg.requirements"
  requirement_count="$(wc -l "$pkg.requirements" | cut -d' ' -f1)"
  echo "Examining $requirement_count requirements."
  requirement_index=0
  local req
  while read -r req
  do
    requirement_index="$(expr "$requirement_index" '+' 1)"
    echo "Inspecting $req ($requirement_index / $requirement_count)"
    yum resolvedep "$req" -q -e 0 -d 0 2>/dev/null | cut -d':' -f'2-' \
      >> "$pkg.dependencies.unsorted"
  done < "$pkg.requirements"
  sort "$pkg.dependencies.unsorted" | uniq > "$pkg.dependencies.unstripped"

  # Process all requirements.
  touch "$pkg.dependencies"
  local dep
  while read -r dep
  do
    local stripped_dep="$(yum info "$dep" \
      | sed -nre 's@^Name\s*:\s+(\S+)\s*$@\1@gp')"
    echo "$stripped_dep" >> "$pkg.dependencies"
    convert_yum_package "$stripped_dep"
    cd "$WORKDIR"
  done < "$pkg.dependencies.unstripped"

  # Finalize conversion.
  echo "Converting '$pkg' to TGZ"
  "$(DIR)/rpm_to_tar.sh" \
    --rpm="$rpm" \
    --out="$WORKDIR/$pkg.tar.gz"
  touch "$pkg.done"

  # Publish TGZ and support files.
  local n
  for n in dependencies version tar.gz done
  do
    cp "$pkg.$n" "$outdir/"
  done
}

convert_yum_package "${F_pkg_name}"
