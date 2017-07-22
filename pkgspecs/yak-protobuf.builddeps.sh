#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep curl # used by protobuf's buildsystem to fetch some dependencies
dep tar
dep unzip # used by protobuf's buildsystem to unpack dependencies
dep autoconf
dep automake
dep libtool
dep make
dep gcc
