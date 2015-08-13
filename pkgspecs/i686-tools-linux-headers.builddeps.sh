#!/bin/bash
set -Eeo pipefail

# To download and extract source code:
echo tar
echo wget

# For whatever reason, make mrproper requires gcc despite being nothing but
# filesystem operations.
echo gcc
