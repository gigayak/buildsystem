# /bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -z "$_FLAG_SH_INCLUDED" ]]
then
  return 0
fi
_FLAG_SH_INCLUDED=1

source "$DIR/escape.sh" # needed for some eval'ed array manipulation :[

# Allows you to add and parse flags in a program.
# Flags are always long flags, because short flags hurt readability.
# Usage:
#
#   #!/bin/bash
#   set -Eeo pipefail
#   DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#   source "$DIR/flag.sh"
#   add_flag test_flag dflt "A test flag."
#   parse_flags
#   echo "Test flag value: $F_test_flag"

_flags=()
declare -A _flag_descriptions
declare -A _flag_defaults
declare -A _flag_default_set
declare -A _flag_boolean
declare -A _flag_array
declare -A _flag_optional
declare -A _flag_exists

# These are for mock data!  Update the tests if you change their names.
_program_name="$(basename "$0")"
_program_params=("$0" "$@")

# Add special help flag by default.
_flags+=("help")
_flag_descriptions["help"]="Displays this help message."
_flag_defaults["help"]="Display."
_flag_boolean["help"]="1"
_flag_array["help"]="0"
_flag_optional["help"]="1"
_flag_exists["help"]="1"

add_flag()
{
  local _opts=("${FUNCNAME[0]}" "$@")
  local retval
  local _vars
  _vars="$(getopt \
    --longoptions "help,boolean,array,required,default:" \
    --name "${FUNCNAME[0]}" \
    -- \
    "${_opts[@]}")"
  retval="$?"
  if (( "$retval" ))
  then
    echo "${FUNCNAME[0]}: getopt puked status code $retval" >&2
    return 1
  fi

  local _name
  local _description
  local _default
  local _has_default=0
  local _boolean=0
  local _optional=1
  local _array=0

  eval set -- "$_vars"
  while true
  do
    local _optname="$1"
    case "$_optname" in
    --boolean)
      _boolean=1
      shift
      ;;
    --array)
      _array=1
      shift
      ;;
    --required)
      _optional=0
      shift
      ;;
    --default)
      if (( "$_has_default" ))
      then
        echo "${FUNCNAME[0]}: cannot set two defaults for flag" >&2
        return 1
      fi
      _default="$2"
      _has_default=1
      shift 2
      ;;
    --)
      shift
      break
      ;;
    --help)
      echo "Usage: ${FUNCNAME[0]} [OPTIONS] <name> <description>" >&2
      echo >&2
      echo "Options:" >&2
      echo "  --help: Shows this help message." >&2
      echo "  --array: Causes results to be stored in an array, and allows" >&2
      echo "           for multiple instances of the flag." >&2
      echo "  --boolean: Causes the flag to accept no value.  True or false.">&2
      echo "  --default=<default>: Sets a default value for the flag." >&2
      echo "  --required: Makes the flag required." >&2
      echo >&2
      echo "NOTE: --required OR --default is required, and the two are" >&2
      echo "      mutually exclusive." >&2
      return 1
      ;;
    *)
      echo "opts: ${_opts[@]}"
      echo "${FUNCNAME[0]}: unrecognized option '$_optname'" >&2
      return 1
      ;;
    esac
  done

  # Sanity checks!  YAY!
  if (( "$_optional" && ! "$_array" && ! "$_has_default" ))
  then
    echo "${FUNCNAME[0]}: must pass either --default=<dflt> or --required" >&2
    return 1
  fi
  if (( "$_array" && "$_has_default" ))
  then
    echo "${FUNCNAME[0]}: cannot set a default for an array" >&2
    # It's just really painful to serialize or deserialize arrays in bash.
    # It's also likely a shellshock style vulnerability in the making.
    return 1
  fi
  if [[ "$_name" == "help" ]]
  then
    echo "${FUNCNAME[0]}: cannot use reserved word 'help' as a flag name" >&2
    return 1
  fi

  # Remaining arguments: name and description
  _name="$1"
  _description="$2"
  if [[ -z "$_name" ]]
  then
    echo "${FUNCNAME[0]}: no flag name given" >&2
    return 1
  fi
  if [[ -z "$_description" ]]
  then
    echo "${FUNCNAME[0]}: no flag description given" >&2
    return 1
  fi

  if (( "${_flag_exists[$_name]}" ))
  then
    echo "${FUNCNAME[0]}: duplicate definition of flag --$_name" >&2
    return 1
  fi

  # Pre-initialize array to make sure +=(val) works properly.
  if (( "$_array" ))
  then
    declare -a "F_$_name"
  fi

  _flags+=("$_name")
  _flag_descriptions["$_name"]="$_description"
  _flag_exists["$_name"]="1"
  _flag_default_set["$_name"]="$_has_default"
  _flag_defaults["$_name"]="$_default"
  _flag_boolean["$_name"]="$_boolean"
  _flag_array["$_name"]="$_array"
  _flag_optional["$_name"]="$_optional"
}

usage()
{
  echo "Usage: $_program_name <option>" >&2
  echo >&2
  echo "Options:" >&2

  local name
  for name in "${_flags[@]}"
  do
    # TODO: this logic is way too complicated and unreadable
    echo -n "  --$name" >&2
    if (( ! "${_flag_boolean[$name]}" )) \
      && (( "${_flag_optional[$name]}" ))
    then
      echo -n "=[${_flag_defaults[$name]}]" >&2
    elif (( "${_flag_array[$name]}" ))
    then
      echo -n "=<value> (mult. ok)"
    elif (( ! "${_flag_optional[$name]}" ))
    then
      echo -n "=<value>"
    fi
    echo -n ": " >&2
    echo "${_flag_descriptions[$name]}" >&2
  done
}

parse_flags()
{
  # Generate list of flags to parse.
  local flaglist=""
  local name
  for name in "${_flags[@]}"
  do
    if [[ ! -z "$flaglist" ]]
    then
      flaglist="${flaglist},"
    fi

    if (( "${_flag_boolean[$name]}" ))
    then
      flaglist="${flaglist}${name}"
    else
      flaglist="${flaglist}${name}:" # trailing colon for "give a value, please"
    fi
  done

  # Parse out each flag to a variable name.
  local retval
  local vars
  vars="$(getopt \
    --longoptions "$flaglist" \
    --name "$_program_name" \
    -- \
    "${_program_params[@]}")"
  retval="$?"
  if (( "$retval" ))
  then
    echo "${FUNCNAME[0]}: getopt puked status code $retval" >&2
    return 1
  fi
  eval set -- "$vars"
  while true
  do
    local name="$1"

    # Cease parsing at --, the universal argument stopper.
    if [[ "$name" == "--" ]]
    then
      shift
      break
    fi

    # Strip out leading --
    if [[ "${name:0:2}" == "--" ]]
    then
      name="${name:2}"
    else
      echo "${FUNCNAME[0]}: got flag name '$name', want prefix '--'" >&2
      return 1
    fi

    if [[ "$name" == "help" ]]
    then
      usage
      return 1
    fi

    if (( ! "${_flag_exists[$name]}" ))
    then
      echo "${FUNCNAME[0]}: got unknown flag --$name" >&2
      return 1
    fi

    local val
    if (( "${_flag_boolean[$name]}" ))
    then
      val="1"
      shift
    else
      local val="$2"
      shift 2
    fi

    local dest="F_${name}"
    if (( "${_flag_array[$name]}" ))
    then
      eval "$dest+=($(sq "$val"))"
      export "$dest"
    else
      export "$dest"="$val"
    fi
  done

  for name in "${_flags[@]}"
  do
    local dest="F_${name}"
    # Note that the [ ! -n ... ] test checks whether a variable is defined.
    # Doing $dest="" still quiets this check (but not [[ -z ... ]]).
    # For example:
    #   a=""
    #   [[ -z "$a" ]] && echo "yes" # echoes yes
    #   [ ! -n "$a" ]] && echo "yes" # silence
    if (( ! "${_flag_optional[$name]}" )) && [ ! -n "${!dest+1}" ]
    then
      echo "${FUNCNAME[0]}: required flag --$name missing" >&2
      return 1
    fi
  done
}
