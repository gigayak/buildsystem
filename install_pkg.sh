#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/flag.sh"
source "$DIR/cleanup.sh"
add_flag --required pkg_name "Name of the package to install."
add_flag --default="/var/www/html/tgzrepo" repo_path "Path to find packages."
add_flag --required install_root "Directory to install package to."
parse_flags

if [[ -z "$F_pkg_name" ]]
then
  echo "$(basename "$0"): package name cannot be blank" >&2
  exit 1
fi
echo "$(basename "$0"): installing package '$F_pkg_name' and deps" >&2

# Create list of installed packages if not already present.
pkglist="$F_install_root/.installed_pkgs"
if [[ ! -e "$pkglist" ]]
then
  touch "$pkglist"
fi

# Some package names contain characters that are special to the grep -E parser.
# This should escape those.
re_escape()
{
  echo "$@" \
    | sed -r \
      -e 's@\\@\\\\@g' \
      -e 's@\^@\\^@g' \
      -e 's@\$@\\$@g' \
      -e 's@\+@\\+@g' \
      -e 's@\{@\\{@g' \
      -e 's@\}@\\}@g' \
      -e 's@\[@\\[@g' \
      -e 's@\]@\\]@g' \
      -e 's@\(@\\(@g' \
      -e 's@\)@\\)@g' \
      -e 's@\.@\\.@g' \
      -e 's@\*@\\*@g'
}

# Resolve all missing dependencies.
orig_deps_path="$F_repo_path/$F_pkg_name.dependencies"
if [[ ! -e "$orig_deps_path" ]]
then
  echo "$(basename "$0"): no dependencies for '$F_pkg_name' found" >&2
  echo "$(basename "$0"): expected at '$orig_deps_path'" >&2
  exit 1
fi
make_temp_dir scratch
new_deps="$scratch/deps.new"
tmp_deps="$scratch/deps.tmp"
old_deps="$scratch/deps.old"
# Dependencies ordered in reverse order of installation - lets us start with the
# package requested, and then append as we discover new requirements.
ordered_deps="$scratch/deps.ordered"
touch "$old_deps"
# Start with package requested.
echo "$F_pkg_name" > "$new_deps"
touch "$ordered_deps"

while read -r new_dep
do
  if [[ -z "$new_dep" ]]
  then
    continue
  fi

  # Avoid reprocessing the same dependency twice - as this could cause an
  # infinite loop in the event of circular dependencies.
  if grep \
    -E "^$(re_escape "$new_dep")\$" \
    "$ordered_deps" \
    >/dev/null 2>&1
  then
    continue
  fi

  # Avoid reprocessing an already-installed dependency.  This likely helps save
  # a good amount of time.
  if grep \
    -E "^$(re_escape "$new_dep")\$" \
    "$F_install_root/.installed_pkgs" \
    >/dev/null 2>&1
  then
    continue
  fi

  # Here's where we actually commit it to the ordered list.
  echo "$new_dep" >> "$ordered_deps"
  echo "$(basename "$0"): found dependency '$new_dep'" >&2

  # Process all of its sub-dependencies.
  deps_path="$F_repo_path/$new_dep.dependencies"
  while read -r dep
  do
    if [[ -z "$dep" ]]
    then
      continue
    fi
    rm -f "$tmp_deps"
    # If we've already logged the dependency, it means it's needed sooner.
    # We'll pull it earlier into the install process.
    if grep \
      -E "^$(re_escape "$dep")\$" \
      "$ordered_deps" \
      >/dev/null 2>&1
    then
      grep \
        -v \
        -E "^$(re_escape "$dep")\$" \
        "$ordered_deps" \
        > "$tmp_deps" \
        || true
      echo "$dep" >> "$tmp_deps"
      mv -f "$tmp_deps" "$ordered_deps"
    # Otherwise, it's new to us - mark it as such, and we iterate deeper.
    else
      # This line is a little subtle - note that the outermost loop is reading
      # from the file we're appending to here.
      #
      # Note that the following example would be an infinite loop::
      #   echo test > test
      #   while read -r t
      #   do
      #     echo "$t"
      #     echo "more test" >> test
      #   done < test
      #
      # The loop appends to its input before it reaches EOF, causing it to find
      # more input.  This is the closest bash comes to a Go channel.
      echo "$dep" >> "$new_deps"
    fi
  done < "$deps_path"
done < "$new_deps"

# Remember that the ordered dependencies are in reverse order...
tac "$ordered_deps" > "$tmp_deps"
mv -f "$tmp_deps" "$ordered_deps"

# Now install all of the required packages in proper dependency order.
while read -r dep
do
  if [[ -z "$dep" ]]
  then
    continue
  fi

  found=1
  grep -E "^$(re_escape "$dep")\$" "$pkglist" >/dev/null 2>&1 || found=0
  if (( "$found" ))
  then
    echo "$(basename "$0"): found package '$dep'; skipping" >&2
    continue
  fi

  echo "$(basename "$0"): installing package '$dep'" >&2
  pkgpath="$F_repo_path/$dep.tar.gz"
  if [[ ! -e "$pkgpath" ]]
  then
    echo "$(basename "$0"): could not find package '$dep'" >&2
    exit 1
  fi
  tar -zxf "$pkgpath" --directory "$F_install_root"
  echo "$dep" >> "$pkglist"
done < "$ordered_deps"

