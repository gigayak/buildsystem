#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep git # can't export git dep in Python :(
dep python-gitzebo # configured module

dep rootfiles # .bashrc needed for HOME and the like

dep go-https-fileserver # to serve repos over dumb HTTPS

dep openssh-server # needed to accept pushes and serve pulls
