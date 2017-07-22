# /bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# These configuration values are intentionally omitted, so that you have to set
# them to values appropriate for you within your ~/.yakrc.sh (or whereever).
# bootstrap.sh does this using commandline flags, and should eventually have an
# interactive prompt when not provided.
#set_config DOMAIN example.com

set_config REPO_LOCAL_PATH "/var/www/html/tgzrepo"
set_config REPO_URL "https://repo.example.com"
set_config CONTAINER_SUBNET "192.168.122.0/24"
set_config LOCAL_STORAGE_PATH "$(DIR)/../localstorage"

# These bits ensure that we provide both the local development directory as
# well as the overarching system install directory if we've got a local clone
# checked out.
#
# Note that this may have the side effect of including a local development
# directory in a production configuration if someone just uses ./dump_config.sh
# to generate their production configuration... while in a locally-cloned
# copy of the buildsystem.
#
# TODO: Look into automatically avoiding this in the git clone; build use case.
pkgspec_dirs=()
if [[ "$(DIR)" != "/usr/bin/buildsystem" ]]
then
  pkgspec_dirs+=("$(DIR)/pkgspecs")
fi
if [[ -d "/usr/bin/buildsystem" ]]
then
  pkgspec_dirs+=("/usr/bin/buildsystem/pkgspecs")
fi
set_config PKGSPEC_DIRS "$(export IFS=':'; echo "${pkgspec_dirs[*]}")"
