#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*-*/
nimble install
