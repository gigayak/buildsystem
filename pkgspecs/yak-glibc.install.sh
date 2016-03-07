#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/glibc-build
make install
make localedata/install-locales
