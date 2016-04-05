#!/bin/bash
set -Eeo pipefail

mkdir -pv /etc/ssl/certs
cp "$YAK_WORKSPACE/certs/"*.pem /etc/ssl/certs/
cat "$YAK_WORKSPACE/certs/"*.pem > /etc/ssl/ca-bundle.crt
