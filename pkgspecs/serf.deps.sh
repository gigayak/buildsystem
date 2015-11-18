#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep apr
dep apr-util
dep openssl
