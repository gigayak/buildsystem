#!/bin/bash
set -Eeo pipefail

mkdir /usr/share/vim/vimfiles/bundle

plugin_dir=""
if [[ -e "/usr/share/vim/vimfiles/plugin" ]]
then
  plugin_dir="/usr/share/vim/vimfiles/plugin"
else
  plugin_dir="$(find /usr/share/vim/vim* -iname plugin -type d)"
fi
if [[ -z "$plugin_dir" ]]
then
  echo "Could not find vim plugin directory." >&2
  exit 1
fi
cat > "$plugin_dir/pathogenconfig.vim" <<EOF
" Configure a system-wide bundle path, for system packaging of plugins
execute pathogen#infect('/usr/share/vim/vimfiles/bundle/{}')
EOF
