#!/bin/bash
set -Eeo pipefail

gem list --local fpm \
  | sed -nre 's@^fpm \(([0-9.]+)\)$@\1@gp'
