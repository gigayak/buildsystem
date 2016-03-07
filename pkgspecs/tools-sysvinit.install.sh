#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd "$YAK_WORKSPACE"/sysvinit-*/
make -C src ROOT=/tools/i686 install

# sysvinit configuration
# TODO: Move configuration into separate package?
cat > /tools/i686/etc/inittab << "EOF"
id:3:initdefault:

si::sysinit:/tools/i686/etc/rc.d/init.d/rc sysinit

l0:0:wait:/tools/i686/etc/rc.d/init.d/rc 0
l1:S1:wait:/tools/i686/etc/rc.d/init.d/rc 1
l2:2:wait:/tools/i686/etc/rc.d/init.d/rc 2
l3:3:wait:/tools/i686/etc/rc.d/init.d/rc 3
l4:4:wait:/tools/i686/etc/rc.d/init.d/rc 4
l5:5:wait:/tools/i686/etc/rc.d/init.d/rc 5
l6:6:wait:/tools/i686/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/tools/i686/sbin/shutdown -t1 -a -r now

su:S016:once:/tools/i686/sbin/sulogin

1:2345:respawn:/tools/i686/sbin/agetty --noclear -I '\033(K' tty1 9600
2:2345:respawn:/tools/i686/sbin/agetty --noclear -I '\033(K' tty2 9600
3:2345:respawn:/tools/i686/sbin/agetty --noclear -I '\033(K' tty3 9600
4:2345:respawn:/tools/i686/sbin/agetty --noclear -I '\033(K' tty4 9600
5:2345:respawn:/tools/i686/sbin/agetty --noclear -I '\033(K' tty5 9600
6:2345:respawn:/tools/i686/sbin/agetty --noclear -I '\033(K' tty6 9600

c0:12345:respawn:/tools/i686/sbin/agetty --noclear 115200 ttyS0 vt100
EOF

