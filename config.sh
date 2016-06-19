#!/bin/bash
[[ "$_" != "$0" ]] && sourced=1 || sourced=0
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}
if [[ ! -z "$_CONFIG_SH_INCLUDED" ]] && (( "$sourced" ))
then
  return 0
fi
_CONFIG_SH_INCLUDED=1

source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"

declare -A _CONFIG_DESCRIPTIONS
declare -A _CONFIG_VALUES
_CONFIG_PATH_COMMANDS=()

create_config()
{
  add_flag --required name "Name of configuration variable."
  add_flag --required description "Description of variable's purpose."
  parse_flags "$@"

  if [[ "${_CONFIG_DESCRIPTIONS[$F_name]+_}" ]]
  then
    log_rote "cannot redeclare config variable '$F_name'"
    return 1
  fi

  _CONFIG_DESCRIPTIONS["$F_name"]="$F_description"
}

set_config()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <variable name> <value>" >&2
    return 1
  fi
  name="$1"
  value="$2"

  if [[ ! "${_CONFIG_DESCRIPTIONS[$name]+_}" ]]
  then
    log_rote "unknown config variable '$name'"
    log_rote "known variables include:"
    for var in "${!_CONFIG_DESCRIPTIONS[@]}"
    do
      log_rote "- $var"
    done
    return 1
  fi
  _CONFIG_VALUES["$name"]="$value"
}

get_config()
{
  if (( "$#" != 1 ))
  then
    echo "Usage: ${FUNCNAME[0]} <variable name>" >&2
    return 1
  fi
  name="$1"

  if [[ ! "${_CONFIG_DESCRIPTIONS[$name]+_}" ]]
  then
    log_rote "unknown config variable '$name'"
    log_rote "known variables include:"
    for var in "${!_CONFIG_DESCRIPTIONS[@]}"
    do
      log_rote "- $var"
    done
    return 1
  fi
  echo "${_CONFIG_VALUES[$name]}"
}

# These allow tests to override the PATH, which allows them to do really dirty
# aliasing for stubs.  This is not how to do dependency injection correctly...
path_append()
{
  _CONFIG_PATH_COMMANDS+=("path_append $(sq "$*")")
  export PATH="${PATH}:$*"
}
path_prepend()
{
  _CONFIG_PATH_COMMANDS+=("path_prepend $(sq "$*")")
  export PATH="$*:${PATH}"
}

create_config --name=DOMAIN \
  --description="Where this instance of Gigayak is hosted."
create_config --name=CONTAINER_SUBNET \
  --description="Subnet specification for container network a la 10.0.0.0/8."
create_config --name=REPO_LOCAL_PATH \
  --description="Working copy of package repository; stores package output."
create_config --name=REPO_URL \
  --description="Upstream URL of package repository; has reference packages."

# config_paths contains a list of paths which will be searched for
# configuration details in the order of search.  Later entries can override
# earlier entries.
#
# config_paths may contain:
#   - file paths ending in .sh
#   - directory names containing files ending in .sh
config_paths=()
config_paths+=("$(DIR)/default_config.sh")
config_paths+=("/.build_workspace/buildsystem/inherited_config.sh")
for prefix in /etc /usr/etc /usr/local/etc
do
  config_paths+=("${prefix}/yak_config.sh")
  config_paths+=("${prefix}/yak.config.d/")
done
config_paths+=("$HOME/.yakrc.sh")
# YAK_TEST_CONFIG allows test scripts to override the configuration without
# having to drop files into locations obeyed outside of tests.  This prevents
# test code from accidentally polluting the global configuration if it fails
# to clean up properly.
if [[ ! -z "$YAK_TEST_CONFIG" ]]
then
  config_paths+=("$YAK_TEST_CONFIG")
fi
for config_path in "${config_paths[@]}"
do
  if (( ! "$sourced" ))
  then
    log_rote "looking for configuration in '$config_path'"
  fi
  if [[ -e "$config_path" ]]
  then
    # This inner loop allows subdirectories to be expanded.
    while read -r config_subpath
    do
      source "$config_subpath"
    done < <(find "$config_path" -type f -iname '*.sh')
  fi
done

for var in "${!_CONFIG_DESCRIPTIONS[@]}"
do
  if [[ ! "${_CONFIG_VALUES[$var]+_}" ]]
  then
    log_rote "no value found for '$var'"
    exit 1
  fi
  if (( ! "$sourced" ))
  then
    log_rote "${var}=${_CONFIG_VALUES[$var]}" 
  fi
done
