#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep xproto
dep xextproto
dep xtrans
dep libxcb
dep kbproto
dep inputproto
