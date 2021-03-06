#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
cd "$YAK_WORKSPACE"/coreutils-*/
make install

# HACK SCALE: MAJOR
#
# Disable bash's hash map, as we're about to move the mv command.
# Once it's moved from /usr/bin/mv, the bash hash map will cause
# bash to continue to look for mv at /usr/bin/mv, even though it
# now exists at /bin/mv.
set +h

# Per CLFS book:
#   Move programs to the locations specified by the FHS
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date} /bin
mv -v /usr/bin/{dd,df,echo,false,hostname,ln,ls,mkdir,mknod} /bin
mv -v /usr/bin/{mv,pwd,rm,rmdir,stty,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
