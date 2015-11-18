#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep wget
dep tar
dep gcc
dep scons

dep openssl-devel
