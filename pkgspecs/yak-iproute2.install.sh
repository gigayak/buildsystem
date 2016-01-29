#!/bin/bash
set -Eeo pipefail

cd /root/*-*/
make DOCDIR="/usr/share/doc/iproute2-$(</root/version)" install
