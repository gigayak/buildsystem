#!/bin/bash
set -Eeo pipefail
# This file is derivative of cURL.  Additional licenses apply  to this file.
# Please see LICENSE.md for details.
#
# You won't find the original script easily by grepping for pieces of this one.
# This is actually a port to bash from Perl of the mk-ca-bundle script, whose
# original can be found at:
#   https://github.com/curl/curl/blob/master/lib/mk-ca-bundle.pl
#
# Why do something as silly as porting from Perl to bash (instead of, say, not
# porting at all, or porting to Python)?
#
# Porting from Perl seemed necessary as getting CPAN set up was proving
# troublesome at the time.
#
# Since the script largely manipulates subprocess calls to the openssl CLI
# binary, it's well suited for a shell script rather than something higher
# level.  Also: the rest of Gigayak's buildsystem is in bash already, so there's
# the added benefit of consistency.
cd "$YAK_WORKSPACE"


# TODO: Figure out how to use HTTPS so that security-minded folks don't suffer
# an aneurysm from this script...
urldir="http://hg.mozilla.org/releases/mozilla-release/raw-file/default/"
url="${urldir}/security/nss/lib/ckfw/builtins/certdata.txt"
crtdir="$YAK_WORKSPACE/certs"
mkdir -pv "$crtdir"

wget "$url"

# Configure which certificates will be consumed
declare -A valid_trust_purposes
for purpose in DIGITAL_SIGNATURE NON_REPUDIATION KEY_ENCIPHERMENT \
  DATA_ENCIPHERMENT KEY_AGREEMENT KEY_CERT_SIGN CRL_SIGN SERVER_AUTH \
  CLIENT_AUTH CODE_SIGNING EMAIL_PROTECTION IPSEC_END_SYSTEM IPSEC_TUNNEL \
  IPSEC_USER TIME_STAMPING STEP_UP_APPROVED
do
  valid_trust_purposes["$purpose"]=1
done
declare -A desired_trust_purposes
desired_trust_purposes["SERVER_AUTH"]=1
declare -A valid_trust_levels
for level in TRUSTED_DELEGATOR NOT_TRUSTED MUST_VERIFY_TRUST TRUSTED
do
  valid_trust_levels["$level"]=1
done
declare -A desired_trust_levels
desired_trust_levels["TRUSTED_DELEGATOR"]=1
declare -A valid_signature_algorithms
for algo in MD5 SHA1 SHA256 SHA384 SHA512
do
  valid_signature_algorithms["$algo"]=1
done
declare -A desired_signature_algorithms
desired_signature_algorithms["MD5"]=1

_is_valid()
{
  local _valid="$@"
  if [[ -z "$_valid" ]]
  then
    echo 1
    return
  fi
  if (( "$_valid" ))
  then
    echo 0
    return
  fi
  echo 1
}
is_valid_trust_level()
{
  if [[ -z "$1" ]]
  then
    return 1
  fi
  return "$(_is_valid "${valid_trust_levels[$1]}")"
}
is_desired_trust_level()
{
  if [[ -z "$1" ]]
  then
    return 1
  fi
  return "$(_is_valid "${desired_trust_levels[$1]}")"
}
is_valid_trust_purpose()
{
  if [[ -z "$1" ]]
  then
    return 1
  fi
  return "$(_is_valid "${valid_trust_purposes[$1]}")"
}
is_desired_trust_purpose()
{
  if [[ -z "$1" ]]
  then
    return 1
  fi
  return "$(_is_valid "${desired_trust_purposes[$1]}")"
}

# Read certificate data we just downloaded line by line
reset_state_machine()
{
  in_cert_data=0
  in_octal_data=0
  octal_data=""
  in_trust_data=0

  ca_name=""
}
reset_state_machine
while read -r line
do
  # Skip comments and blank lines.
  if \
    echo "$line" | grep -E '^\s*\#' >/dev/null 2>&1 \
    || echo "$line" | grep -E '^\s*$' >/dev/null 2>&1
  then
    continue
  fi

  # Find start of certificate.
  if \
    (( ! "$in_cert_data" )) \
    && echo "$line" \
      | grep -E '^\s*CKA_CLASS\s+CK_OBJECT_CLASS\s+CKO_CERTIFICATE\s*$' \
      >/dev/null 2>&1
  then
    reset_state_machine
    in_cert_data=1
    echo "found cert data"
    continue
  fi
  if (( ! "$in_cert_data" ))
  then
    continue
  fi

  # Find CA name.
  if \
    (( ! "$in_octal_data" && ! "$in_trust_data" )) \
    && echo "$line" \
      | grep -E '^\s*CKA_LABEL\s+UTF8' >/dev/null 2>&1
  then
    reset_state_machine
    in_cert_data=1
    ca_name="$(echo "$line" \
      | sed -nre 's@^\s*CKA_LABEL\s+UTF8\s+"([^"]*)"\s*$@\1@gp')"
    echo "cert name: $ca_name"
    continue
  fi

  # Parse octal data section.
  if \
    (( ! "$in_octal_data" )) \
    && [[ -z "$octal_data" ]] \
    && echo "$line" \
      | grep -E '^\s*CKA_VALUE\s+MULTILINE_OCTAL' \
      >/dev/null 2>&1
  then
    in_octal_data=1
    echo "found octal data"
    continue
  elif \
    (( "$in_octal_data" )) \
    && echo "$line" \
      | grep -E '^\s*END' \
      >/dev/null 2>&1
  then
    in_octal_data=0
    echo "exited octal data"
    continue
  elif (( "$in_octal_data" ))
  then
    octal_data="${octal_data}${line}"
    continue
  fi

  # Parse trust section.
  if \
    (( ! "$in_trust_data" )) \
    && echo "$line" \
      | grep -E '^\s*CKA_CLASS\s+CK_OBJECT_CLASS\s+CKO_NSS_TRUST\s*$' \
      >/dev/null 2>&1
  then
    in_trust_data=1
    echo "found trust data"
    continue
  elif (( "$in_trust_data" )) \
    && echo "$line" \
      | grep -E '^\s*END\s*$' \
      >/dev/null 2>&1
  then
    in_trust_data=0
    echo "exited trust data"
    continue
  else
    if echo "$line" \
      | grep -E '^CKA_TRUST_[A-Z_]+\s+CK_TRUST\s+CKT_NSS_[A-Z_]+\s*$' \
      >/dev/null 2>&1
    then
      purpose="$(echo "$line" | sed -nr \
        -e 's@^CKA_TRUST_([A-Z_]+)\s+CK_TRUST\s+CKT_NSS_[A-Z_]+\s*$@\1@gp')"
      if ! is_valid_trust_purpose "$purpose"
      then
        echo "Encountered invalid trust purpose '$purpose'" >&2
        continue
      fi
      level="$(echo "$line" | sed -nr \
        -e 's@^CKA_TRUST_[A-Z_]+\s+CK_TRUST\s+CKT_NSS_([A-Z_]+)\s*$@\1@gp')"
      if ! is_valid_trust_level "$level"
      then
        echo "Encountered invalid trust level '$level'" >&2
        continue
      fi
      echo "Found trust purpose '$purpose' at level '$level'"
      if is_desired_trust_purpose "$purpose" && is_desired_trust_level "$level"
      then
        crtname="$(echo "$ca_name" \
          | tr '[:space:]' '_' \
          | sed -re 's@[^A-Za-z0-9_-]@@g' -e 's@[_-]$@@g').pem"
        crtpath="$crtdir/$crtname"
        echo "Outputting certificate to $crtpath."
        echo "-----BEGIN CERTIFICATE-----" > "$crtpath"
        # echo -e causes octal data to be parse; -n prevents trailing \n
        # sed sequence on octal data enforces leading \0, as echo -e ignores
        #   octal escapes without a leading \0.  (\140 doesn't work.)
        echo "$(echo -en "$(echo -n "$octal_data" | sed -re 's@\\@\\0@g')" \
          | base64 --wrap=64 -)" \
          >> "$crtpath"
        echo "-----END CERTIFICATE-----" >> "$crtpath"

        # TODO: Do sanity checks, such as validating hashes.
        #for signature_algorithm in "${!desired_signature_algorithms[@]}"
        #do
        #  openssl x509 -"$signature_algorithm" \
        #    -fingerprint -noout -inform PEM -in "$crtpath"
        #done
      fi
    fi
    continue
  fi

  # Look for end of certificate data.
  if \
    (( "$in_cert_data" )) \
    && echo "$line" \
      | grep -E '^\s*END\s*$' \
      >/dev/null 2>&1
  then
    in_cert_data=0
    echo "exiting cert data"
    continue
  fi

  echo "OTHER: $line"
done < "certdata.txt"
