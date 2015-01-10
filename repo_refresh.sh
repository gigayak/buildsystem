#!/bin/bash
set -Eeo pipefail
cd /var/www/html/repo
rm -rf repodata
createrepo "$PWD"
