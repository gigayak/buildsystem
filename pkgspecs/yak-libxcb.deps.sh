#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep xcb-proto
dep libpthread-stubs
dep libxau
