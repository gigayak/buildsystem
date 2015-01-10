#!/bin/bash

lib=setuptools
python -c "import ${lib}; print ${lib}.__version__"
