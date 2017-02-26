#!/bin/bash
set -Eeo pipefail

# This package creates the dependency mapping used by modprobe to locate the
# complete list of kernel modules to load.

# Note that we may be running the kernel from tools-linux or an older kernel at
# this time, so the default /lib/modules/$(uname -r) path must be overridden to
# prevent an attempt to read from the incorrect /lib/modules directory (even
# though this will be redundant in the "I'm rebuilding my current kernel"
# use case).  Providing the desired version number explicitly accomplishes this.
#
# TODO: Fetch kernel version via versioning API when one exists...
depmod \
  --all \
  --errsyms \
  --filesyms /boot/System.map \
  "$(basename /lib/modules/*/)"
