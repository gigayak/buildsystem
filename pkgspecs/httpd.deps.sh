#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep apr
dep apr-util
dep pcre
dep gcc