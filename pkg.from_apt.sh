#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"
source "$DIR/flag.sh"
source "$DIR/buildtools/all.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags "$@"

pkgname="$F_pkg_name"

# Do dependency translation if available.
translation="$(HOST_OS=ubuntu dep "$pkgname")"
if [[ "$pkgname" != "$translation" ]]
then
  echo "$(basename "$0"): translated name '$pkgname' to '$translation'" >&2
fi

built_original_name=0
while read -r dep
do
  # Don't dare to recurse into ./pkg.from_apt.sh --pkg_name=''.  That makes
  # apt-cache dotty '' yield a nice Perl error:
  #
  #   terminate called after throwing an instance of 'std::out_of_range'
  #   what():  basic_string::compare
  if [[ -z "$dep" ]]
  then
    continue
  fi

  # Don't attempt to recursively build self, as that will infinitely loop.
  if [[ "$dep" == "$pkgname" ]]
  then
    built_original_name=1
    continue
  fi

  # Do not attempt to build translated dependencies here, as it will break
  # cycle detection if you're not careful to preserve dependency history.
done < <(echo "$translation")

# Do no more work if the originally requested package no longer exists after
# translation.
if [[ "$pkgname" != "$translation" ]] && (( ! "$built_original_name" ))
then
  "$DIR/pkg.alias.sh" --target="$translation" --alias="$pkgname"
  exit 0
fi

# Fire the packaging script.
args=()
args+=(--pkg_name="$pkgname")
args+=(--builddeps_script="$DIR/apt.builddeps.sh")
args+=(--install_script="$DIR/apt.install.sh")
args+=(--version_script="$DIR/apt.version.sh")
args+=(--deps_script="$DIR/apt.deps.sh")
if [[ "$pkgname" != "$translation" ]]
then
  make_temp_file deps_script
  (
    echo '#!/bin/bash'
    echo 'set -Eeo pipefail'
    echo 'source "$BUILDTOOLS/all.sh"'
    echo "$translation" \
      | sed -re 's@^@dep @g'
  ) > "$deps_script"
  args+=(--deps_script="$deps_script")
fi
args+=(--break_dependency_cycles)

"$DIR/pkg.sh" \
  "${args[@]}" \
  "${ARGS[@]}"

