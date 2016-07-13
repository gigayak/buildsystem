#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
source "$(DIR)/buildtools/all.sh"
add_flag --required pkg_name "Name of the package to build."
parse_flags "$@"

pkgname="$F_pkg_name"

# Do dependency translation if available.
#
# Note: this will break if --target_architecture or --target_distribution
# are added incorrectly in the future.
arch="$("$(DIR)/os_info.sh" --architecture)"
os=ubuntu
qual_name="$(qualify_dep "$arch" "$os" "$pkgname")"
translated_deps=()
while read -r translated_dep
do
  if [[ "$translated_dep" == "." || -z "$translated_dep" ]]
  then
    continue
  fi
  translated_deps+=("$translated_dep")
done < <(dep --arch="$arch" --distro="$os" "$pkgname")
if (( ! "${#translated_deps[@]}" ))
then
  log_fatal "translated name $(sq "$qual_name") to nothing at all"
fi

is_translated=0
if (( "${#translated_deps[@]}" != 1 )) \
  || [[ \
    "$(qualify_dep "$arch" "$os" "${translated_deps[0]}")" != "$qual_name" \
    && "${translated_deps[0]}" != "$pkgname" \
  ]]
then
  is_translated=1
  log_rote "translated name '$qual_name' to:"
  for translation in "${translated_deps[@]}"
  do
    log_rote " - $(sq "$translation")"
  done
fi

built_original_name=0
for dep in "${translated_deps[@]}"
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
  qual_dep="$(qualify_dep "$arch" "$os" "$dep")"

  # Don't attempt to recursively build self, as that will infinitely loop.
  if [[ "$dep" == "$pkgname" || "$qual_dep" == "$qual_name" ]]
  then
    built_original_name=1
    continue
  fi

  # Do not attempt to build translated dependencies here, as it will break
  # cycle detection if you're not careful to preserve dependency history.
done

# Do no more work if the originally requested package no longer exists after
# translation.
if (( "$is_translated" && ! "$built_original_name" ))
then
  target_flags=()
  for target in "${translated_deps[@]}"
  do
    target_flags+=("--target=$target")
  done
  "$(DIR)/pkg.alias.sh" --alias="$pkgname" "${target_flags[@]}"
  exit 0
fi

# Fire the packaging script.
args=()
args+=(--target_architecture="$arch")
args+=(--target_distribution="$os")
args+=(--pkg_name="$pkgname")
args+=(--builddeps_script="$(DIR)/apt.builddeps.sh")
args+=(--install_script="$(DIR)/apt.install.sh")
args+=(--version_script="$(DIR)/apt.version.sh")
args+=(--deps_script="$(DIR)/apt.deps.sh")
if (( "$is_translated" ))
then
  make_temp_file deps_script
  (
    echo '#!/bin/bash'
    echo 'set -Eeo pipefail'
    echo 'source "$YAK_BUILDTOOLS/all.sh"'
    echo "$translation" \
      | sed -re 's@^@dep @g'
  ) > "$deps_script"
  args+=(--deps_script="$deps_script")
fi
args+=(--break_dependency_cycles)

"$(DIR)/pkg.sh" \
  "${args[@]}" \
  "${ARGS[@]}"

