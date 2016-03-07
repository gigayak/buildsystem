#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep openssl
dep libcurl
dep expat
dep perl
dep tcl
