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

# Save off configuration values that we set so that we can double-check they
# were set successfully later.  See hack explanation below.
expected_values=()

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
  expected_values+=("CONFIG_$key=$val")

  pattern='^(CONFIG_'"$key"'=).*$'
  if grep -E "$pattern" .config >/dev/null 2>&1
  then
    # TODO: Escape $val here!
    replace='\1'"$val"
    expr="s@$pattern@$replace@g"
    mv -f .config .config.tmp
    sed -re "$expr" .config.tmp > .config
    rm -f .config.tmp
  else
    echo "CONFIG_${key}=$val" >> .config
  fi
  return 0
}

# /dev needs to be handled by the kernel or we won't see ANY devices due to the
# lack of MAKEDEV scripts.
set_config DEVTMPFS y
# HP Smart Array driver - needed for P410i on HP DL380g7.
set_config SCSI_LOWLEVEL y # required for SCSI_HPSA
set_config SCSI_HPSA y # SCSI driver itself
# TODO: Find out if the latter is required for HPSA...
#set_config BLK_CPQ_DA y # SMART2 driver

# HACK SCALE: MINOR
#
# Configuration dance!  If we set the above options, then our kernel
# configuration suddenly has more options available to it as it expands
# stuff like SCSI_LOWLEVEL to all of the newly-allowable config options.
# As a result of realizing that some options were never explicitly set
# to a value, it will attempt to prompt us for values - but since we're
# an automated buildsystem, this just causes a hang.
#
# `make allnoconfig` allows us to create a configuration file with
# every prompt answered by "no".  It also accepts an option via an
# environment variable `KCONFIG_ALLCONFIG`, which is to contain the file
# name of a minimal required kernel configuration - which overrides all
# "no" answers for any configuration variables within.
#
# By providing our incomplete configuration to `KCONFIG_ALLCONFIG` and
# invoking `make allnoconfig`, we automatically answer all prompts with
# "no", but retain our desired configuration.  Note that this can cause
# configuration values to "evaporate", though: if we set a value that
# depends on another variable being in a certain state, then kconfig
# will erase the value we set if its requirement is not fulfilled. To
# avoid this from hoisting us - we double-check our final `.config` file
# to ensure that all variables we set were retained after the
# `make allnoconfig` step...
cp -vf .config config.partial
make KCONFIG_ALLCONFIG=config.partial allnoconfig
for e in "${expected_values[@]}"
do
  if ! grep -E "^$e\$" .config >/dev/null 2>&1
  then
    echo "Could not find setting '$e' in .config" >&2
    exit 1
  fi
done

# Build the kernel
echo "Building the kernel"
make ARCH=i386 CROSS_COMPILE=${CLFS_TARGET}-
