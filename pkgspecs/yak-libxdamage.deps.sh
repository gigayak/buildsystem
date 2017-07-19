#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep damageproto
dep libxfixes
dep fixesproto
