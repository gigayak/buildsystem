#!/bin/bash
set -Eeo pipefail
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# from builddeps.txt
cat /root/deplist.txt
