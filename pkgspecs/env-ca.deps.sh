#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep certificate-authority
dep rootfiles
dep bash
