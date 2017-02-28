#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# For signing kernel modules:
dep openssl
dep wget || dep --distro=tools2 wget
dep tar || dep --distro=tools2 tar
dep make || dep --distro=tools2 make
dep diffutils || dep --distro=tools2 diffutils
dep gcc
dep bc
dep perl
