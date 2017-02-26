#!/bin/bash

# Utility library for builds dealing with the Linux kernel's configuration
# system.
#
# Use:
#   kconfig_init allnoconfig
#   kconfig_set SCSI_LOWLEVEL y
#   make

kconfig_init()
{
  # Clean everything up.  Apparently, source tarballs are not necessarily clean.
  make mrproper

  # Copy in a default configuration.  This allows us to just track configuration
  # changes in this file.
  make "$@"

  # Save off the desired value.
  cp -v ".config" "config.initial"
}

# Allow us to edit the configuration.
# TODO: use flag.sh
kconfig_set()
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

  if [[ "$val" == "n" ]]
  then
    echo "# CONFIG_$key is not set" >> "config.explicit"
  else
    echo "CONFIG_$key=$val" >> "config.explicit"
  fi

  return 0
}

kconfig_kernel_finalize_hack()
{
  # Use official kernel configuration merging script, which is closest that
  # I could find to an official commandline kconfig utility...
  #
  # Where keys overlap, later arguments take priority over earlier arguments.
  scripts/kconfig/merge_config.sh "config.initial" "config.explicit"
}

