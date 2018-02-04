#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep go
dep go-dep
dep git # for go-dep to wield
