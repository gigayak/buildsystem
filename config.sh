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

declare -A _CONFIG_DESCRIPTIONS
declare -A _CONFIG_VALUES

create_config()
{
  add_flag --required name "Name of configuration variable."
  add_flag --required description "Description of variable's purpose."
  parse_flags "$@"

  if [[ "${_CONFIG_DESCRIPTIONS[$F_name]+_}" ]]
  then
    echo "${FUNCNAME[0]}: cannot redeclare config variable '$F_name'" >&2
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
    echo "${FUNCNAME[0]}: unknown config variable '$name'" >&2
    echo "${FUNCNAME[0]}: known variables include:" >&2
    for var in "${!_CONFIG_DESCRIPTIONS[@]}"
    do
      echo "${FUNCNAME[0]}: - $var" >&2
    done
    return 1
  fi
  _CONFIG_VALUES["$name"]="$value"
}

create_config --name=DOMAIN \
  --description="Where this instance of Gigayak is hosted."
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
for config_path in "${config_paths[@]}"
do
  if (( ! "$sourced" ))
  then
    echo "$(basename "$0"): looking for configuration in '$config_path'" >&2
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
    echo "$(basename "$0"): no value found for '$var'" >&2
    exit 1
  fi
  if (( ! "$sourced" ))
  then
    echo "$(basename "$0"): YAK_${var}=${_CONFIG_VALUES[$var]}" >&2 
  else
    export "YAK_${var}"="${_CONFIG_VALUES[$var]}"
  fi
done
