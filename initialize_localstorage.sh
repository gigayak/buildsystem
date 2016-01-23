#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: This whole script is a horrific TODO.  Better bootstrap needed.
#
# (This is a "quick hack" that will "hopefully only be around for a few
# months" - meaning, I'll be eating these words in February 2020.)

# TODO: Use a .gitignore-ed subdirectory if a global directory is not ready.
tgt="$( cd "$DIR/.." && pwd )/localstorage"
if [[ -e "$tgt" ]]
then
  echo "$(basename "$0"): local storage directory '$tgt' already exists." >&2
  exit 1
fi

mkdir -pv "$tgt"
cd "$tgt"
mkdir -v {certificate-authority,dns,gitzebo,proxy,repo,www}

# Replica symlinks:
# * certificate-authority has no container instances
# * dns and gitzebo both write data, and cannot be replicated easily
# * others are read-only and can have replicas, so two are used for ease of
#   in-flight updates without downtimes
ln -sv dns dns-01
ln -sv gitzebo gitzebo-01
ln -sv proxy proxy-01
ln -sv proxy proxy-02
ln -sv repo repo-01
ln -sv repo repo-02
ln -sv www www-01
ln -sv www www-02

# Mountpoints for each container type:
mkdir -pv certificate-authority/ca/{authority,certificates,keys,requests}
mkdir -pv dns/{dns,logs}
mkdir -pv gitzebo/{db,logs,repo,ssl}
mkdir -pv proxy/{logs,ssl}
mkdir -pv repo/{logs,ssl}
mkdir -pv www/{logs,ssl}

# Hack to enable DNS:
# TODO: Shouldn't this be in env-dns.install.sh?!
cat > dns/dns/_base.conf <<'EOF'
no-resolv
server=8.8.8.8
addn-hosts=/opt/dns/hosts.autogen
dhcp-range=interface:virbr0,192.168.122.10,192.168.122.254,1h
EOF

# Make sure to kick off certificate generation - these are inserted into the
# empty directories we just created, and most services won't start without
# certificates and keys.
bash -x "$DIR/create_crypto.sh"
