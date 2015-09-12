#!/bin/bash
set -e
set -E
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#require ca-certificates wget
pkg_name="go"
pkg_version="1.4.1" # TODO: version crawler
echo "$pkg_version" > "/root/go.version"
pkg_ext="tar.gz"
pkg_url="https://storage.googleapis.com/golang/${pkg_name}${pkg_version}.src.${pkg_ext}"
pkg_path="$DIR/${pkg_name}-${pkg_version}-src.${pkg_ext}"
pkg_archs=("x86_64" "i386") # valid architectures
pkg_arch="i386" # selected architecture

# Timing and logging handler. (Overengineering.)
milestone()
{
  if (( "$#" != 1 ))
  then
    echo "$(basename "$0"): accepts only one argument for the moment"
    return 1
  fi
  echo "$1..."
}



milestone "retrieving package"
if [[ ! -f "$pkg_path" ]]
then
  # TODO: --no-check-certificates considered harmful; remove
  #       (it exists purely because RHEL version of wget is ancient)
  wget "$pkg_url" \
    --no-check-certificate \
    --output-document="$pkg_path"
else
  echo "Package '$(basename "$pkg_path")' already exists."
fi


milestone "extracting package"
tar -zxf "$pkg_path"


milestone "building"
cd go/src
case "$pkg_arch" in
x86_64|amd64)
  export GOARCH=amd64
  ;;
arm7h)
  export GOARCH=arm
  export GOARM=7
  ;;
i686|i586|i486|i386)
  export GOARCH=386
  ;;
*)
  echo "$(basename "$0"): unknown architecture '$pkg_arch'" >&2
  exit 5
esac
source make.bash --no-banner
