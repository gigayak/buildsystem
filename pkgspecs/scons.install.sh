#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*-*/
python setup.py install
