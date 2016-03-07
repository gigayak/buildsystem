#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Get.
dep wget
dep tar

# Build.
dep gcc

