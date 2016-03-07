#!/bin/bash
set -Eeo pipefail

# Take a snapshot of apt-get databases to prevent changes to those databases
# from making it into the final image.
mkdir -p "$YAK_WORKSPACE/backups/"{lib,log,cache}
cp --preserve=all -r /var/cache/apt "$YAK_WORKSPACE/backups/cache/"
cp --preserve=all -r /var/lib/apt "$YAK_WORKSPACE/backups/lib/"
cp --preserve=all -r /var/log/apt "$YAK_WORKSPACE/backups/log/"
cp --preserve=all -r /var/lib/dpkg "$YAK_WORKSPACE/backups/lib/"
cp --preserve=all /var/log/dpkg.log "$YAK_WORKSPACE/backups/log/"

# This prevents "debconf: unable to initialize frontend" errors.
#   Per: https://github.com/phusion/baseimage-docker/issues/58
export DEBIAN_FRONTEND="noninteractive"

cd "$YAK_WORKSPACE"

# Don't use apt-get to install the package, as there's no way to get it to
# avoid installing dependencies.  Since the Gigayak packager installed those
# dependencies and did not update the dpkg database, it will try to re-install
# all dependencies, which causes O(N^2) system build times and network traffic,
# and will likely cause file conflicts when copy_diff_files.sh executes.
apt-get download "$YAK_PKG_NAME"
pkg_count="$(find . -mindepth 1 -maxdepth 1 -iname '*.deb' | wc -l)"
if (( "$pkg_count" != 1 ))
then
  echo "$(basename "$0"): $pkg_count packages downloaded instead of 1" >&2
  exit 1
fi

# HACK SCALE: MINOR
#
# For some reason, Ubuntu does not appear to fully export PATH, which results
# in "dpkg: error: PATH is not set" on the dpkg execution line.  This just...
# exports the PATH variable to prevent that.
export PATH
dpkg -i --force-depends *.deb

# Save off version number now, as version script will run after we blow away
# the apt-get / dpkg administrative directories / databases, and this command
# will fail at that point (claiming that the package isn't installed).
dpkg -s "$YAK_PKG_NAME" \
  | sed -nre 's@^Version: (.*)$@\1@gp' \
  > "$YAK_WORKSPACE/version"

rm -rf /var/cache/apt
rm -rf /var/lib/apt
rm -rf /var/log/apt
rm -rf /var/lib/dpkg
rm -f /var/log/dpkg.log

cp --preserve=all -r "$YAK_WORKSPACE/backups/cache/apt" /var/cache/
cp --preserve=all -r "$YAK_WORKSPACE/backups/lib/apt" /var/lib/
cp --preserve=all -r "$YAK_WORKSPACE/backups/log/apt" /var/log/
cp --preserve=all -r "$YAK_WORKSPACE/backups/lib/dpkg" /var/lib/
cp --preserve=all "$YAK_WORKSPACE/backups/log/dpkg.log" /var/log/
rm -rf "$YAK_WORKSPACE/backups"
