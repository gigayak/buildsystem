#!/bin/bash
set -Eeo pipefail
version="$(cat "$YAK_WORKSPACE/version")"

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

cd "$YAK_WORKSPACE"/*-*/
cd autoload
cp -v *.vim "$plugin_dir/"
