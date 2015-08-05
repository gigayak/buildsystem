#!/bin/bash
set -Eeo pipefail

# To download from source.
echo git

# To ensure trust of git server.
echo enable-dynamic-ca-certificates
echo internal-ca-certificates
