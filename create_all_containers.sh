#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

container()
{
  name="$1"
  replica_index="$2"
  ip="$3"

  container_name="${name}-${replica_index}"
  package_name="env-${name}"

  if lxc-ls -l \
    | awk '{print $9}' \
    | grep -e '^'"$container_name"'$'
  then
    echo "Skipping already-created container '$container_name'"
  else
    echo "Creating container '$container_name'"
    "$DIR/create_container.sh" \
      --name="$container_name" \
      --pkg="$package_name" \
      --ip="$ip"
  fi

  if lxc-info -n "$container_name" \
    | grep -e '^State:' \
    | grep RUNNING
  then
    echo "Skipping already-running container '$container_name'"
  else
    echo "Launching container '$container_name'"
    "$DIR/launch_container.sh" \
      --name="$container_name"
    # TODO: launch_container.sh needs to be replica aware for localstorage/logs
    #       reasons.  At the moment, all replicas compete for the same files,
    #       which is silly.
  fi
}

#container gitzebo 01 192.168.122.5 # TODO: This should be uncommented.
# Above is commented to prevent gitzebo and gitzebo-01 from conflicting.
container dns     01 192.168.122.6
container dns     02 192.168.122.7
