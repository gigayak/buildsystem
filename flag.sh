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
#   parse_flags "$@"
#   echo "Test flag value: $F_test_flag"
#
# Commandline arguments (stuff after a '--' token) are preserved and exported
# as the ${ARGS[@]} array.
#
# ABSOLUTELY NEVER define flags in a loop, as flag redefinitions from the same
# location in code will be ignored.

_flags=()
_usage_notes=()
declare -A _flag_program_names
declare -A _flag_names
declare -A _flag_descriptions
declare -A _flag_defaults
declare -A _flag_default_set
declare -A _flag_boolean
declare -A _flag_array
declare -A _flag_optional
declare -A _flag_exists
declare -A _flag_definition_location

# Function to return a scoping identifier for flags, to allow multiple flag
# scopes to exist - one for the top-level main, and then one per function.
#
# Caveat: DOES NOT SUPPORT RECURSION.  It silently fails for recursive cases,
# as it isn't aware of recursion at all.
#
# Returns "main@:" for functions called from a top-level shell script.
# Returns "func@source.sh:" for a function name func called from source.sh.
flag_scope()
{
  echo "${FUNCNAME[2]}@${BASH_SOURCE[3]}:"
}

# Function to return exact location at which caller was called.   This serves
# as a unique identifier for each flag definition, allowing distinct flag
# definitions for the same name to result in errors without having multiple
# calls to a function that defines flag barf.
flag_location()
{
  echo "${BASH_SOURCE[2]}:${BASH_LINENO[1]}"
}

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

  local _scope="$(flag_scope)"
  local _name
  local _description
  local _default
  local _has_default=0
  local _boolean=0
  local _optional=1
  local _array=0
  local _definition_location="$(flag_location)"

  eval set -- "$_vars"
  while true
  do
    local _optname="$1"
    case "$_optname" in
    --boolean)
      _boolean=1
      _default=0
      _has_default=1
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
      if (( "$_boolean" ))
      then
        echo "${FUNCNAME[0]}: booleans default to false for now" >&2
        return 1
      fi
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

  # Remaining arguments: name and description
  _name="$1"
  _description="$2"
  local _id="${_scope}${_name}"

  # Sanity checks!  YAY!
  if [[ -z "$_name" ]]
  then
    echo "${FUNCNAME[0]}: no flag name given" >&2
    return 1
  fi
  if [[ "$_name" == "help" ]]
  then
    echo "${FUNCNAME[0]}: cannot use reserved word 'help' as a flag name" >&2
    return 1
  fi
  if (( "${_flag_exists[$_id]}" ))
  then
    # Ignore multiple flag definitions from the same spot in code - they
    # should theoretically not be based on variables, and thus have the exact
    # same parameters each time.  This situation will come up whenever flags
    # are defined in a function that is called multiple times.
    if [[ "${_flag_definition_location[$_id]}" == "$_definition_location" ]]
    then
      return 0
    fi
    echo "${FUNCNAME[0]}: duplicate definition of flag --$_name" >&2
    return 1
  fi
  if [[ -z "$_description" ]]
  then
    echo "${FUNCNAME[0]}: --$_name: no flag description given" >&2
    return 1
  fi
  if (( "$_optional" && ! "$_array" && ! "$_has_default" && ! "$_boolean" ))
  then
    echo "${FUNCNAME[0]}: --$_name: must have default, required, or boolean" >&2
    return 1
  fi
  if (( "$_array" && "$_has_default" ))
  then
    echo "${FUNCNAME[0]}: --$_name: cannot set a default for an array" >&2
    # It's just really painful to serialize or deserialize arrays in bash.
    # It's also likely a shellshock style vulnerability in the making.
    return 1
  fi

  _flags+=("$_id")
  _flag_names["$_id"]="$_name"
  _flag_descriptions["$_id"]="$_description"
  _flag_exists["$_id"]="1"
  _flag_default_set["$_id"]="$_has_default"
  _flag_defaults["$_id"]="$_default"
  _flag_boolean["$_id"]="$_boolean"
  _flag_array["$_id"]="$_array"
  _flag_optional["$_id"]="$_optional"
  _flag_definition_location["$_id"]="$_definition_location"
}

usage()
{
  local _scope="$1"
  local _program_name=""
  if [[ ! -z "$_scope" ]]
  then
    _program_name="${_flag_program_names[${_scope}]}"
  fi
  if [[ -z "$_program_name" ]]
  then
    _program_name="<unknown program name>"
  fi

  echo "Usage: ${_program_name} <option>" >&2
  echo >&2

  if [[ ! -z "$_scope" ]]
  then
    if (( "${#_usage_notes}" ))
    then
      for _note in "${_usage_notes[@]}"
      do
        if [[ \
          "$(echo "$_note" \
            | head -n 1 \
            | sed -nre 's@([^:]+:).*$@\1@gp' \
          )" != "$_scope" \
        ]]
        then
          continue
        fi
        echo "${_note}" | head -n 1 | sed -nre 's@^[^:]+:(.*)$@\1@gp' >&2
        echo "${_note}" | tail -n +2 >&2
      done
    fi
  else
    echo "WARNING: Usage notes not available due to unknown program name." >&2
  fi

  echo "Options:" >&2

  local _name
  local _id
  for _id in "${_flags[@]}"
  do
    _name="$(echo "$_id" | sed -nre 's@^[^:]+:(.*)$@\1@gp')"
    # TODO: this logic is way too complicated and unreadable
    echo -n "  --$_name" >&2
    if (( ! "${_flag_boolean[$_id]}" )) \
      && (( "${_flag_optional[$_id]}" ))
    then
      echo -n "=[${_flag_defaults[$_id]}]" >&2
    elif (( "${_flag_array[$_id]}" ))
    then
      echo -n "=<value> (mult. ok)"
    elif (( ! "${_flag_optional[$_id]}" ))
    then
      echo -n "=<value>"
    fi
    echo -n ": " >&2
    echo "${_flag_descriptions[$_id]}" >&2
  done
}

# add_usage_note feeds in a usage note to tag the script with.
# Usage: add_usage_note <<EOF
# yadda yadda yadda
# EOF
add_usage_note()
{
  local _scope="$(flag_scope)"
  DONE=false
  OLD_IFS="$IFS"
  IFS="\n"
  until "$DONE"
  do
    read -r _note || DONE=true
    _usage_notes+=("${_scope}${_note}")
  done
  IFS="$OLD_IFS"
}

# Usage: parse_flags "$@"
#
# Parses all flags for the currently-executing program or function.
#
# See documentation at top of library for how to define flags.
parse_flags()
{
  # Generate list of flags to parse.
  local flaglist="help"
  local _callername
  local _scope="$(flag_scope)"
  if [[ "$_scope" == "main@:" ]]
  then
    _callername="${BASH_SOURCE[1]}"
  else
    _callername="${FUNCNAME[1]}"
  fi
  if [[ -z "${_flag_program_names[$_scope]}" ]]
  then
    _flag_program_names["$_scope"]="$_callername"
  fi

  local dest
  local name
  for name in "${_flags[@]}"
  do
    if [[ "$(echo "$name" | sed -nre 's@^([^:]+:).*$@\1@gp')" != "$_scope" ]]
    then
      continue
    fi
    name="$(echo "$name" | sed -nre 's@^[^:]+:(.*)$@\1@gp')"

    # Unset already-set variable destinations.  This prevents being able to
    # export F_required to override the --required argument to add_flag.
    dest="F_${name}"
    if [ -n "${!dest+1}" ]
    then
      unset "$dest"
    fi

    if [[ ! -z "$flaglist" ]]
    then
      flaglist="${flaglist},"
    fi

    if (( "${_flag_boolean[${_scope}${name}]}" ))
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
    --name "$_callername" \
    -- \
    "$_callername" "$@")"
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
      usage "$_scope"
      return 1
    fi

    if (( ! "${_flag_exists[${_scope}${name}]}" ))
    then
      echo "${FUNCNAME[0]}: got unknown flag --$name" >&2
      return 1
    fi

    local val
    if (( "${_flag_boolean[${_scope}${name}]}" ))
    then
      val="1"
      shift
    else
      val="$2"
      shift 2
    fi

    dest="F_${name}"
    if (( "${_flag_array[${_scope}${name}]}" ))
    then
      eval "$dest+=($(sq "$val"))"
      export "$dest"
    else
      export "$dest"="$val"
    fi
  done

  # Save off remaining arguments in ${ARGS[@]} with a bash array copy.
  ARGS=("$@")
  export ARGS

  for name in "${_flags[@]}"
  do
    if [[ "$(echo "$name" | sed -nre 's@^([^:]+:).*$@\1@gp')" != "$_scope" ]]
    then
      continue
    fi
    name="$(echo "$name" | sed -nre 's@^[^:]+:(.*)$@\1@gp')"

    local dest="F_${name}"
    local _id="${_scope}$name"
    # Note that the [ ! -n ... ] test checks whether a variable is defined.
    # Doing $dest="" still quiets this check (but not [[ -z ... ]]).
    # For example:
    #   a=""
    #   [[ -z "$a" ]] && echo "yes" # echoes yes
    #   [ ! -n "$a" ]] && echo "yes" # silence
    if (( "${_flag_default_set[$_id]}" )) && [ ! -n "${!dest+1}" ]
    then
      export "$dest"="${_flag_defaults[$_id]}"
    fi
    if (( ! "${_flag_optional[$_id]}" )) && [ ! -n "${!dest+1}" ]
    then
      echo "${FUNCNAME[0]}: required flag --$name missing" >&2
      return 1
    fi
  done
}
