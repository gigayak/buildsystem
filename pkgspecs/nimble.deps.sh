#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep nim
dep openssl # SSL is needed to access HTTPS repositories.
dep git # Similarly, git repositories are downloaded via git.
