#!/bin/bash
set -Eeo pipefail

version="$(</root/version)"
cd /root/*-*/
make PREFIX=/usr install
