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
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg"
  start_case "basic directory creation"
  [[ -d "$pkg/etc/silliness" ]] && pass || fail
  run_exit_handlers
)

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  touch "$post/test_file"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg"
  start_case "basic file creation"
  [[ -f "$pkg/test_file" ]] && pass || fail
  run_exit_handlers
)

(
  make_temp_dir pre
  make_temp_dir post
  make_temp_dir pkg
  mknod "$post/null" c 1 3
  chmod 666 "$post/null"
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg"
  start_case "basic character device creation existence check"
  [[ -c "$pkg/null" ]] && pass || fail
  start_case "basic character device major/minor check"
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
  ddiff "$post" "$pre" | "$copy_diff_files" "$post" "$pkg"
  start_case "basic symlink creation existence check"
  [[ -L "$pkg/symlink" ]] && pass || fail
  start_case "basic symlink creation target check"
  [[ "$(readlink "$pkg/symlink")" == "/path/does/not/exist" ]] \
    && pass || fail
  run_exit_handlers
)
