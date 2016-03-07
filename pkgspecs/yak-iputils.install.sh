#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
install -v -m755 ping /bin
install -v -m755 clockdiff /usr/bin
install -v -m755 rdisc /usr/bin
install -v -m755 tracepath /usr/bin
install -v -m755 trace{path,route}6 /usr/bin
# TODO: fix manpage build and installation (they aren't built!)
#install -v -m644 doc/*.8 /usr/share/man/man8
ln -sv ping /bin/ping4
ln -sv ping /bin/ping6

