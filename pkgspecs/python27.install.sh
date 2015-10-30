#!/bin/bash
set -Eeo pipefail
cd /root/*/

# `make altinstall` does not install `/usr/bin/python`.
# It should only install `/usr/bin/python2.7`.
make altinstall
