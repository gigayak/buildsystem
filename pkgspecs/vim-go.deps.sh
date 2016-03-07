#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep vim # to install into
dep vim-pathogen # to register the plugins
dep vim-pathogen-config # to register the plugins
