#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep certificate-authority
dep filesystem-skeleton
dep bash
