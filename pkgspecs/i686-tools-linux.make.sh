#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=3.18.3
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/kernel/v3.x/linux-$version.tar.xz"
wget "$url"

tar -Jxf "linux-$version.tar.xz"
cd linux-*/

# Clean everything up.  Apparently, source tarballs are not necessarily clean.
make mrproper

# Copy in a default configuration.  This allows us to just track configuration
# changes in this file.
make defconfig

# Save off a copy of the configuration to install to /opt/kernel.config.default
cp -v .config /root/kernel.config.default

# Allow us to edit the configuration.
set_config()
{
  key="$1"
  if [[ -z "$key" ]]
  then
    echo "set_config called without a key" >&2
    return 1
  fi
  val="$2"
  if [[ -z "$key" ]]
  then
    echo "set_config called without a value" >&2
    return 1
  fi


  echo "Setting 'CONFIG_$key' to '$val'"

  pattern='^(CONFIG_'"$key"'=).*$'
  if grep -E "$pattern" .config
  then
    # TODO: Escape $val here!
    replace='\1'"$val"
    expr="s@$pattern@$replace@g"
    echo "sed expr: $expr" # TODO: delme
    mv .config .config.tmp
    sed -re "$expr" .config.tmp > .config
    rm .config.tmp
  else
    echo "CONFIG_${key}=$val" >> .config
  fi
  return 0
}

# /dev needs to be handled by the kernel or we won't see ANY devices due to the
# lack of MAKEDEV scripts.
set_config DEVTMPFS y

# Build the kernel
echo "Building the kernel"
make ARCH=i386 CROSS_COMPILE=${CLFS_TARGET}-
