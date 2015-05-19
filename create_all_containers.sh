#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

container()
{
  name="$1"
  replica_index="$2"

  container_name="${name}-${replica_index}"
  package_name="env-${name}"

  if lxc-ls -l \
    | awk '{print $9}' \
    | grep -e '^'"$container_name"'$'
  then
    echo "Skipping already-created container '$container_name'"
    return
  else
    echo "Creating container '$container_name'"
    "$DIR/create_container.sh" \
      --name="$container_name" \
      --pkg="$package_name"
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

# Everything requires the DNS servers.  Always boot these first.
container dns     01
container dns     02

# Infrastructure services:
container gitzebo 01

# Package management:
container repo    01
container repo    02

# Exit is somewhat ambiguous - make it clear.
echo "All containers exist and are online."
