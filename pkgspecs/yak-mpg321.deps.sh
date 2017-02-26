#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep libmad
dep libid3tag
dep libao
dep alsa-lib
dep zlib
