#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep glproto
dep libdrm
dep dri2proto
dep libx11
dep libxdamage
dep libxext
dep libxfixes
dep libxshmfence
dep libelf
dep expat
