#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget \
  || dep --distro=tools2 wget
dep tar \
  || dep --distro=tools2 tar
dep make \
  || dep --distro=tools2 make
dep gcc
