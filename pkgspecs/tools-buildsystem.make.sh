#!/bin/bash
set -Eeo pipefail

repo="https://git.jgilik.com/buildsystem.git"

mkdir /root/workspace
cd /root/workspace
git clone "$repo"
