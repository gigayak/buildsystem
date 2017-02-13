#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
# OpenSSL really wants to install into /usr/lib64 on 64-bit systems... so
# LIBDIR=lib is specified to tell it to avoid the usual multilib schema and to
# install into /usr/lib.
make LIBDIR=lib install
