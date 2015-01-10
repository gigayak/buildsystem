#!/bin/bash
set -e
set -E
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Script is at: $DIR"
echo "Current dir: $PWD"
echo "Installing Distribute"
wget https://bootstrap.pypa.io/ez_setup.py
python ez_setup.py
