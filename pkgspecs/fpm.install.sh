#!/bin/bash
set -Eeo pipefail

# TODO: This installs FPM's dependencies, too!  They should be discovered in
#       fpm.deps.sh instead.
gem install fpm
