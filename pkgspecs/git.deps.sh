#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep openssl
dep libcurl
dep expat
dep perl
dep tcl
