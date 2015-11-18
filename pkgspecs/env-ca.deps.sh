#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep certificate-authority
dep rootfiles
