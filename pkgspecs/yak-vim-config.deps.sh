#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep vim
dep bash-profile # in charge of /etc/profile.d
