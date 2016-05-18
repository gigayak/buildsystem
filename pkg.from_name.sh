#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"
source "$(DIR)/repo.sh"
source "$(DIR)/buildtools/all.sh"
add_flag --required pkg_name "Name of the package to build."
add_flag --default "" target_architecture \
  "Architecture to build for.  Default is host's architecture."
add_flag --default "" target_distribution \
  "Distribution to build for.  Default is host's distribution."
parse_flags "$@"

host_distro="$("$(DIR)/os_info.sh" --distribution)"
host_arch="$("$(DIR)/os_info.sh" --architecture)"
arch="$F_target_architecture"
if [[ -z "$arch" ]]
then
  arch="$host_arch"
fi
distro="$F_target_distribution"
if [[ -z "$distro" ]]
then
  distro="$host_distro"
fi
dep="$(qualify_dep "$arch" "$distro" "$F_pkg_name")"
name="$(dep2name "$host_arch" "$host_distro" "$dep")"

constraint_flags=()
constraints_enabled=0
if [[ ! -z "$arch" && "$arch" != "$host_arch" ]]
then
  log_rote "targetting architecture $arch"
  constraint_flags+=(--target_architecture="$arch")
  constraints_enabled=1
fi
if [[ ! -z "$distro" && "$distro" != "$host_distro" ]]
then
  log_rote "targetting distribution $distro"
  constraint_flags+=(--target_distribution="$distro")
  constraints_enabled=1
fi

# Lowercase the package name if needed.  pkg.from_whatever.sh should all
# receive lowercase package names.
lcname="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
if [[ "$lcname" != "$name" ]]
then
  log_rote "lowercasing the package name to '$lcname'"
  name="$lcname"
fi

# DO NOT USE PIP for installing pip and distribute, as these are requirements
# for pip.  (Go figure.)  They need to be built differently, and have specs
# instead.
if [[ "$name" == "python-pip" ]] || [[ "$name" == "python-distribute" ]]
then
  if (( "$constraints_enabled" ))
  then
    log_rote "python-* cannot be built with --target_* flags"
    exit 1
  fi
  "$(DIR)/pkg.from_spec.sh" "--pkg_name=$name" -- "${ARGS[@]}"
  exit $?

# python -> pip
# Note: python-devel is not the "devel" package from PIP, it's a RHEL/CentOS
#   RPM that needs conversion.
# Note: python-dev and python-minimal are similarly Ubuntu packages to convert.
elif [[ \
  "$name" == "python-"* \
  && "$name" != "python-devel" \
  && "$name" != "python-dev" \
  && "$name" != "python-minimal" \
]]
then
  if (( "$constraints_enabled" ))
  then
    log_rote "python-* cannot be built with --target_* flags"
    exit 1
  fi
  # Make sure to remove both the python- prefix and the version restrictions
  # TODO: obey version restrictions
  stripped="$(echo "$name" \
    | sed -nre 's@^python-([a-zA-Z0-9_-]+)([>=<]+[0-9\.]+)?$@\1@gp')"
  if [[ -z "$stripped" ]]
  then
    log_rote "failed to strip pip package name '$name'"
    exit 1
  fi
  "$(DIR)/pkg.from_pip.sh" "--pkg_name=$stripped" -- "${ARGS[@]}"
  exit $?

# tools -> tools2
elif [[ "$distro" == "tools2" ]]
then
  "$(DIR)/pkg.tools_to_tools2.sh" \
  --pkg_name="$name" \
  "${constraint_flags[@]}" \
  -- "${ARGS[@]}"
  exit $?

# try a bootstrap package
elif "$(DIR)/pkg.from_bootstrap.sh" \
  "--pkg_name=$name" \
  "${constraint_flags[@]}" \
  --check_only \
  -- "${ARGS[@]}"
then
  "$(DIR)/pkg.from_bootstrap.sh" \
    "--pkg_name=$name" \
    "${constraint_flags[@]}" \
    -- "${ARGS[@]}"
  exit $?

# try a specced package
elif "$(DIR)/pkg.from_spec.sh" \
  "--pkg_name=$name" \
  "${constraint_flags[@]}" \
  --check_only \
  -- "${ARGS[@]}"
then
  "$(DIR)/pkg.from_spec.sh" \
    "--pkg_name=$name" \
    "${constraint_flags[@]}" \
    -- "${ARGS[@]}"
  exit $?

# go -> go repo
# (below specced packages in case a Go package has a spec)
elif [[ "$name" == "go-"* ]]
then
  if (( "$constraints_enabled" ))
  then
    log_rote "go-* cannot be built with --target_* flags"
    exit 1
  fi
  stripped="$(echo "$name" \
    | sed -nre 's@^go-(.*)$@\1@gp')"
  if [[ -z "$stripped" ]]
  then
    log_rote "failed to strip go package name '$name'"
    exit 1
  fi
  "$(DIR)/pkg.from_go.sh" "--pkg_name=$stripped" -- "${ARGS[@]}"
  exit $?

# try yum conversion on CentOS hosts
elif which yum >/dev/null 2>&1
then
  if (( "$constraints_enabled" ))
  then
    log_rote "yum cannot be converted with --target_* flags"
    exit 1
  fi
  "$(DIR)/pkg.from_yum.sh" --pkg_name="$name" -- "${ARGS[@]}"
  exit $?

# try apt conversion on Ubuntu hosts
elif which apt-get >/dev/null 2>&1
then
  if (( "$constraints_enabled" ))
  then
    log_rote "apt cannot be converted with --target_* flags"
    exit 1
  fi
  "$(DIR)/pkg.from_apt.sh" --pkg_name="$name" -- "${ARGS[@]}"
  exit $?
fi

log_rote "could not find a builder for package '$name'"
exit 1
