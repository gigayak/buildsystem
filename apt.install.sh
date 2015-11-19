#!/bin/bash
set -Eeo pipefail

# Take a snapshot of apt-get databases to prevent changes to those databases
# from making it into the final image.
mkdir -p /root/backups/{lib,log,cache}
cp --preserve=all -r /var/cache/apt /root/backups/cache/
cp --preserve=all -r /var/lib/apt /root/backups/lib/
cp --preserve=all -r /var/log/apt /root/backups/log/
cp --preserve=all -r /var/lib/dpkg /root/backups/lib/
cp --preserve=all /var/log/dpkg.log /root/backups/log/

# This prevents "debconf: unable to initialize frontend" errors.
#   Per: https://github.com/phusion/baseimage-docker/issues/58
export DEBIAN_FRONTEND="noninteractive"

cd /root

# Don't use apt-get to install the package, as there's no way to get it to
# avoid installing dependencies.  Since the Gigayak packager installed those
# dependencies and did not update the dpkg database, it will try to re-install
# all dependencies, which causes O(N^2) system build times and network traffic,
# and will likely cause file conflicts when copy_diff_files.sh executes.
apt-get download "$PKG_NAME"
dpkg -i --force-depends *.deb

# Save off version number now, as version script will run after we blow away
# the apt-get / dpkg administrative directories / databases, and this command
# will fail at that point (claiming that the package isn't installed).
dpkg -s "$PKG_NAME" \
  | sed -nre 's@^Version: (.*)$@\1@gp' \
  > /root/version

rm -rf /var/cache/apt
rm -rf /var/lib/apt
rm -rf /var/log/apt
rm -rf /var/lib/dpkg
rm -f /var/log/dpkg.log

cp --preserve=all -r /root/backups/cache/apt /var/cache/
cp --preserve=all -r /root/backups/lib/apt /var/lib/
cp --preserve=all -r /root/backups/log/apt /var/log/
cp --preserve=all -r /root/backups/lib/dpkg /var/lib/
cp --preserve=all /root/backups/log/dpkg.log /var/log/
rm -rf /root/backups
