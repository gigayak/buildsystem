#!/bin/bash
set -Eeo pipefail
gcc --version | head -n1 | awk '{print $3}'
