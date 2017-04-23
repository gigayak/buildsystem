#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
cd "$YAK_WORKSPACE"/*-*/
make install

# This is a silly fix that mirrors one that should be in shadow > 4.4 (whatever
# the next release is) - as it was ostensibly fixed in shadow-maint/shadow
# PR#43.
for name in \
  su chage chfn chsh expiry gpasswd newgrp passwd \
  chgpasswd chpasswd groupadd groupdel groupmod newusers useradd usermod \
  newgidmap newuidmap
do
  for dir in /bin /usr/bin /sbin /usr/sbin
  do
    if [[ -e "$dir/$name" ]]
    then
      chmod --verbose u+s "$dir/$name"
    fi
  done
done
