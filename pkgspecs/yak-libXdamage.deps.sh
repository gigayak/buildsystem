#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep damageproto
dep libXfixes
dep fixesproto
