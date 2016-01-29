#!/bin/bash
set -Eeo pipefail

cd /root/*-*/
make -C src install
