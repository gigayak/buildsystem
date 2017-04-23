#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"/*-*/
make install

for n in lsmod rmmod insmod modinfo modprobe depmod
do
  ln -sv kmod "/bin/$n"
done
