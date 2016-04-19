#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep openssl
dep curl
dep expat
dep perl
dep tcl
