#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

container()
{
  name="$1"
  ip="$2"

  if lxc-ls -l \
    | awk '{print $9}' \
    | grep -e '^'"$name"'$'
  then
    echo "Skipping already-created container '$name'"
  else
    echo "Creating container '$name'"
    "$DIR/create_container.sh" \
      --name="$name" \
      --pkg="env-$name" \
      --ip="$ip"
  fi

  if lxc-info -n "$name" \
    | grep -e '^State:' \
    | grep RUNNING
  then
    echo "Skipping already-running container '$name'"
  else
    echo "Launching container '$name'"
    "$DIR/launch_container.sh" \
      --name="$name"
  fi
}

container gitzebo 192.168.122.5
container dns     192.168.122.6
