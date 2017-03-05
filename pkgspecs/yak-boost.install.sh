#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/boost_*/
b2 install --prefix=/usr
