#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep gnutls
dep db4
