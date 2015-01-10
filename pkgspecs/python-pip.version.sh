#!/bin/bash
set -Eeo pipefail

lib=pip
python -c "import ${lib}; print ${lib}.__version__"
