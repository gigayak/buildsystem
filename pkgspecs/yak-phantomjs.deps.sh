#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep qt # TODO: is this needed, or are just a bunch of transitive X11 deps needed?
dep icu
