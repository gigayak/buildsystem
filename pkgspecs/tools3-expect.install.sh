#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/expect*/
make SCRIPTS="" install
