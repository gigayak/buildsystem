# /bin/bash
set -Eeo pipefail

# These configuration values are intentionally omitted, so that you have to set
# them to values appropriate for you within your ~/.yakrc.sh (or whereever).
# bootstrap.sh does this using commandline flags, and should eventually have an
# interactive prompt when not provided.
#set_config DOMAIN example.com

set_config REPO_LOCAL_PATH "/var/www/html/tgzrepo"
set_config REPO_URL "https://repo.example.com"
set_config CONTAINER_SUBNET "192.168.122.0/24"
