#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"/*-*/
make install

for n in lsmod rmmod insmod modinfo modprobe depmod
do
  ln -sv kmod "/bin/$n"
done
