#!/bin/bash
set -Eeo pipefail

echo git # can't export git dep in Python :(
echo python-gitzebo # configured module

echo rootfiles # .bashrc needed for HOME and the like

#echo httpd # serve using Apache
#echo mod_wsgi # WSGI used to link to Python

echo openssh-server # needed to accept pushes and serve pulls
