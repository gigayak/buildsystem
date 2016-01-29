#!/bin/bash
set -Eeo pipefail
cd /root/glibc-build
make install
make localedata/install-locales
