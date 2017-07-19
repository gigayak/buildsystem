#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep fixesproto
dep xextproto
dep xproto
dep libx11
