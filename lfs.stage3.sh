#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

echo "Starting stage 3 bootstrap"
echo "This uses tools-buildsystem to build all native packages."

if [[ ! -d "/var/www/html/tgzrepo" ]]
then
  echo "HACK TIME: creating repository directory"
  mkdir -pv "/var/www/html/tgzrepo"
fi
if grep ' /tmp ' /proc/mounts > /dev/null 2>&1
then
  echo "HACK TIME: unmounting /tmp, it isn't big enough"
  umount /tmp
fi

start_from="$@"
waiting=0
if [[ ! -z "$start_from" ]]
then
  waiting=1
fi

build()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <distro> <package>" >&2
    return 1
  fi
  distro="$1"
  pkg="$2"
  if (( "$waiting" )) \
    && [[ "$pkg" != "$start_from" \
      && "${distro}-${pkg}" != "$start_from" ]]
  then
    echo "Ignoring package '$pkg'"
    return 0
  fi
  export waiting=0

  p="${distro}-${pkg}"
  echo "Building package '$p'"
  retval=0
  "$(DIR)/pkg.from_name.sh" \
    --pkg_name="$pkg" \
    --target_distribution="$distro" \
    2>&1 \
    | tee "$logdir/$p.log" \
    || retval=$?
  if (( "$retval" ))
  then
    echo "Building package '$p' failed with code $retval"
    exit 1
  fi
}


build yak filesystem-skeleton
build tools3 tcl
build tools3 expect
build tools3 dejagnu
build tools3 perl
build tools3 texinfo
build tools3 gdb
build yak linux-headers
build yak man-pages
build yak glibc
build tools3 gcc
build tools3 gcc-aliases
build yak m4
build yak gmp
build yak mpfr
build yak mpc
build yak isl
build yak cloog
build yak zlib
build yak flex
build yak bison
build yak binutils
build yak gcc
build yak sed
build yak pkg-config-lite
build yak ncurses
build yak shadow
build yak util-linux
build yak bzip2
build yak coreutils
build yak perl
build yak autoconf
build yak automake
build yak gettext
build yak e2fsprogs
build yak libtool
build yak procps-ng
build yak iana-etc
build yak iproute2
build yak gdbm
build yak readline
build yak bash
build yak bash-aliases
build yak bash-config
build yak bc
build yak diffutils
build yak file
build yak gawk
build yak findutils
build yak grep
build yak groff
build yak less
build yak gzip
build yak iputils
build yak kbd
build yak libpipeline
build yak man
build yak make
build yak xz
build yak kmod
build yak patch
build yak psmisc
build yak libestr
build yak libee
build yak debianutils
build yak eventlog
build yak libffi
build yak python2
build yak glib
build yak pcre
build yak openssl
build yak syslog-ng
build yak sysvinit
build yak sysvinit-config
build yak tar
build yak texinfo
build yak eudev
build yak vim
build yak syslinux
build yak dhcpcd
build yak bootscripts
build yak bootscripts-config
build yak input-config
build yak fstab-config
build yak linux
build yak linux-credentials
build yak nettle
build yak gnutls
build yak wget
build yak go14
build yak go
build yak asciidoc
build yak curl
build yak expat
build yak tcl
build yak git
build yak go-sget
build yak dropbear
build yak dropbear-config
build yak lxc
