#!/bin/bash
set -Eeo pipefail

update_command=()
if [[ "$YAK_HOST_OS" == "centos" ]]
then
  echo "Found CentOS host" >&2
  # force-enable is because there's some sort of integration with RPM to detect
  # if the ca-certificates package is installed or not.  Of course, since we no
  # longer use RPM... that incorrectly reports that it's not installed.
  update_command=(update-ca-trust force-enable)
elif [[ "$YAK_HOST_OS" == "ubuntu" ]]
then
  echo "Found Ubuntu host" >&2
  echo "Dynamic CA certificates are on by default in Ubuntu" >&2
  echo "That makes this package unnecessary and/or a no-op!" >&2
else
  echo "Unknown host OS '$YAK_HOST_OS'" >&2
  exit 1
fi

${update_command[@]}
