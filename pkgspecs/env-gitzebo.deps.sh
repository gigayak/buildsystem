#!/bin/bash
set -Eeo pipefail

echo git # can't export git dep in Python :(
echo python-gitzebo # configured module

echo rootfiles # .bashrc needed for HOME and the like

echo go-https-fileserver # to serve repos over dumb HTTPS

echo openssh-server # needed to accept pushes and serve pulls
