#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Deleting old roots."
"$DIR/env_destroy_all.sh"

echo "Deleting repository."
rm -rf /var/www/html/repo
mkdir /var/www/html/repo
createrepo /var/www/html/repo

echo "Deleting base root cache."
rm -rf "$DIR/cache/baseroot"

# base
pkgs=()
pkgs+=("jpg-repo")
pkgs+=("enable-dynamic-ca-certificates")
pkgs+=("internal-ca-certificates")
pkgs+=("certificate-authority")

# pip
pkgs+=("python-distribute")
pkgs+=("python-pip")
pkgs+=("python-flask")
pkgs+=("python-salt")
pkgs+=("python-gitzebo")

# go
pkgs+=("go")
pkgs+=("go-hello") # test package
pkgs+=("go-git-webserver") # git HTTPS server

# support for vim-go
pkgs+=("ssh-dev-keys-client")
pkgs+=("vim-pathogen")
pkgs+=("vim-pathogen-config")
pkgs+=("vim-go")

# environments (container configurations, really)
pkgs+=("env-ca")
pkgs+=("env-go-dev")
pkgs+=("env-gitzebo")
pkgs+=("env-dns")

for pkg in "${pkgs[@]}"
do
  echo "BUILDING: $pkg"
  retval=0
  "$DIR/pkg.from_name.sh" \
    --pkg_name="$pkg" \
  || retval=$?
  if (( "$retval" ))
  then
    echo "$(basename "$0"): building package '$pkg' failed with code $retval">&2
    exit 1
  fi
  echo "DONE WITH: $pkg"
done

echo "All packages built successfully!"
exit 0
