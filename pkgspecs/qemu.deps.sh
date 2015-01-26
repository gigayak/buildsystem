#!/bin/bash
set -Eeo pipefail

# ./configure asked for headers, so assume we link the following:
echo zlib
echo glib2-devel
