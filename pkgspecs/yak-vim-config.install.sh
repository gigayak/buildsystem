#!/bin/bash
set -Eeo pipefail

# Yak-specific configuration for vim, to make it function somewhat sanely
# out of the box.
cat >> /usr/share/vim/vimrc <<'EOF'
" Allow arrow keys to work in insert mode.
set nocompatible

" Allow backspace to function sanely.
set backspace=indent,eol,start

" Syntax highlighting is great - turn it on...
syntax on
EOF

# Enable the 'vi' alias, which is not installed by default.
cat >> /etc/profile.d/vim.sh <<'EOF'
# /bin/bash
# Create 'vi' alias for vim if it does not already exist.
if ! type vi >/dev/null 2>&1
then
  alias vi=vim
fi
EOF
