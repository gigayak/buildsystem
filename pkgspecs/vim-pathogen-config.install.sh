#!/bin/bash
set -Eeo pipefail

mkdir /usr/share/vim/vimfiles/bundle

cat > /usr/share/vim/vimfiles/plugin/pathogenconfig.vim <<EOF
" Configure a system-wide bundle path, for system packaging of plugins
execute pathogen#infect('/usr/share/vim/vimfiles/bundle/{}')
EOF
