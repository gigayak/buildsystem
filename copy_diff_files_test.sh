#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/cleanup.sh"

start_case()
{
  export case_name="$@"
}
pass()
{
  echo "PASS: $case_name"
}
fail()
{
  echo "FAIL: $case_name"
}

ddiff()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <post-install snapshot> <pre-install>" >&2
    return 1
  fi
  rsync \
    --dry-run --recursive --itemize-changes \
    --links --perms --group --owner \
    --devices --specials \
    "$1/" "$2/"
}

export copy_diff_files="$DIR/copy_diff_files.sh"

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  mkdir -pv "$post/etc/silliness"
  start_case "basic directory case - file copying"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg" && pass || fail
  start_case "basic directory case - existence check"
  [[ -d "$pkg/etc/silliness" ]] && pass || fail
  run_exit_handlers
)

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  touch "$post/test_file"
  start_case "basic file case - file copying"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg" && pass || fail
  start_case "basic file case - existence check"
  [[ -f "$pkg/test_file" ]] && pass || fail
  run_exit_handlers
)

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  mknod "$post/null" c 1 3
  chmod 666 "$post/null"
  start_case "basic character device case - file copying"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg" && pass || fail
  start_case "basic character device case - existence check"
  [[ -c "$pkg/null" ]] && pass || fail
  start_case "basic character device case - major/minor check"
  [[ "$(stat -c '%t,%T' "$pkg/null")" == "1,3" ]] && pass || fail
  start_case "basic character device creation permissions check"
  [[ "$(stat -c '%a' "$pkg/null")" == "666" ]] && pass || fail
  run_exit_handlers
)

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  ln -sv "/path/does/not/exist" "$post/symlink"
  start_case "basic symlink case - file copying"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg" && pass || fail
  start_case "basic symlink case - existence check"
  [[ -L "$pkg/symlink" ]] && pass || fail
  start_case "basic symlink case - target check"
  [[ "$(readlink "$pkg/symlink")" == "/path/does/not/exist" ]] \
    && pass || fail
  run_exit_handlers
)

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  mkdir -pv "$pre/etc/test"
  mkdir -pv "$post/etc/test"
  touch "$post/etc/test/test_file"
  start_case "parent directory case - file copying"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg" && pass || fail
  start_case "parent directory case - directory creation check"
  [[ -d "$pkg/etc/test" ]] && pass || fail
  start_case "parent directory case - child file creation check"
  [[ -f "$pkg/etc/test/test_file" ]] && pass || fail
  run_exit_handlers
)

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  # This creates a file with a name of a single eighth note followed by two
  # sixteenth notes - using UTF-8 Unicode.  rsync has some escaping that it
  # does to make this work...
  touch "$post/"$'\342\231\252\342\231\254'
  start_case "UTF-8 nastiness in filenames case - file copying"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg" && pass || fail
  start_case "UTF-8 nastiness in filenames case - existence check"
  [[ -f "$pkg/"$'\342\231\252\342\231\254' ]] && pass || fail
  run_exit_handlers
)
