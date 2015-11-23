#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# To check if env-... packages for containers exist.
source "$DIR/repo.sh"

container()
{
  name="$1"
  replica_index="$2"

  container_name="${name}-${replica_index}"
  package_name="env-${name}"

  if ! repo_get "${package_name}.done"
  then
    echo "Could not find container environment package '$package_name'" >&2
    "$DIR/pkg.from_name.sh" --pkg_name="${package_name}"
  fi

  if lxc-ls -1 \
    | grep -e '^'"$container_name"'$'
  then
    echo "Skipping already-created container '$container_name'"
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
  fi
}

# Network must be up before containers are created.
"$DIR/create_network.sh"

# Everything requires the DNS servers.  Always boot these first.
container dns     01
container dns     02

# Infrastructure services:
container gitzebo 01
container proxy   01
container proxy   02

# Network scripts will set up port forwarding to proxies if they exist.
"$DIR/create_network.sh"

# Package management:
container repo    01
container repo    02

# Miscellaneous stuff not needed to build:
container www     01

# Exit is somewhat ambiguous - make it clear.
echo "All containers exist and are online."
