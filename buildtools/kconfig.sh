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

  # Save off configuration values that we set so that we can double-check they
  # were set successfully later.  See hack explanation below.
  expected_values=()
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


  expected_values+=("CONFIG_$key=$val")
  pattern_positive='^(CONFIG_'"$key"'=).*$'
  pattern_negative='^# (CONFIG_'"$key"') is not set.*$'
  if grep -E "$pattern_positive" .config >/dev/null 2>&1
  then
    echo "Overwriting 'CONFIG_$key' with '$val'"
    # TODO: Escape $val here!
    replace='\1'"$val"
    expr="s@$pattern_positive@$replace@g"
    mv -f .config .config.tmp
    sed -re "$expr" .config.tmp > .config
    rm -f .config.tmp
  # TODO: Perhaps refactor positive/negative branches together?
  elif grep -E "$pattern_negative" .config >/dev/null 2>&1
  then
    echo "Overwriting 'CONFIG_$key' with '$val'"
    # TODO: Escape $val here!
    replace='\1='"$val"
    expr="s@$pattern_negative@$replace@g"
    mv -f .config .config.tmp
    sed -re "$expr" .config.tmp > .config
    rm -f .config.tmp
  else
    echo "Setting 'CONFIG_$key' to '$val'"
    echo "CONFIG_${key}=$val" >> .config
  fi
  return 0
}

kconfig_kernel_finalize_hack()
{
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
  #
  # Note that if ARCH=... and CROSS_COMPILE=... are left out, then we'll
  # generate a configuration pointing at the incorrect architecture when
  # truly cross compiling (i.e. building arm7 on x86_64), and the make
  # invocation at the end will fail when it starts prompting about
  # options not available on the host architecture.
  cp -vf .config config.partial
  make "$@" \
    KCONFIG_ALLCONFIG=config.partial \
    allnoconfig
  should_die=0
  for e in "${expected_values[@]}"
  do
    if ! grep -E "^$e\$" .config >/dev/null 2>&1
    then
      echo "Could not find setting '$e' in .config" >&2
      should_die=1
    fi
  done
  if (( "$should_die" ))
  then
    exit 1
  fi
}

