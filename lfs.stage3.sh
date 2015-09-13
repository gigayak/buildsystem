#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Starting stage 3 bootstrap"
echo "This uses i686-tools-buildsystem to build all native packages."

if ! ip route show | grep default >/dev/null 2>&1
then
  echo "HACK TIME: set up default route (should be done at init)"
  ip route add default via 10.0.0.1
fi
echo "HACK TIME: point glibc at /etc/hosts"
echo "hosts: files dns" > /etc/nsswitch.conf
echo "HACK TIME: point proxy.jgilik.com at proxy"
echo "10.0.0.10 proxy.jgilik.com" > /etc/hosts
if [[ ! -d "/var/www/html/tgzrepo" ]]
then
  echo "HACK TIME: creating repository directory"
  mkdir -pv "/var/www/html/tgzrepo"
fi

pkgs=()
pkgs+=("i686-tools3-tcl")

build="$DIR/pkg.from_name.sh"
for p in "${pkgs[@]}"
do
  echo "$(basename "$0"): building package '$p'" >&2
  retval=0
  "$build" --pkg_name="$p" || retval=$?
  if (( "$retval" ))
  then
    echo "$(basename "$0"): failed to build package '$p' with code $retval" >&2
    exit 1
  fi
  echo "$(basename "$0"): successfully built package '$p'" >&2
done

source "$DIR/repo.sh"
echo "_REPO_GET=$_REPO_GET"
