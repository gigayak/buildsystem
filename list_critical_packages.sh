#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/log.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/repo.sh"

add_flag --required target_distribution \
  "Which distribution to list minimally required packages for."
add_flag --required target_architecture \
  "Which architecture to list minimally required packages for."
add_flag --boolean build \
  "Whether or not listing packages that need to be built to create an image."
add_flag --boolean install \
  "Whether or not listing packages that need to be installed to install image."
add_usage_note <<EOF
This script outputs all packages strictly required to boot (and install) the
target distribution.  It only really applies to yak/tools/tools2 distributions,
but the list of critical packages was getting duplicated all over the place -
so this file acts to deduplicate that list.

Output will be in fully-qualified dependency format, such as:

  x86_64-yak:bash
  x86_64-yak:gigayak-installer

One package will be output per line.  They will be in build/dependency order.

Only one of --build or --install can be provided.  --build shows the build order
to run package builds, while --install shows only packages that need to be
installed on the final media.
EOF
# TODO: Make this file consider dependency order.

parse_flags "$@"

mutex_flags_set="$((F_build + F_install))"
if (( "$mutex_flags_set" != 1 ))
then
  log_fatal "one and only one of --build and --install expected"
fi

pkgs=()
arch="${F_target_architecture}"
add_pkg() {
  local distro
  distro="$1"
  local package
  package="$2"
  pkgs+=("$(qualify_dep "$arch" "$distro" "$package")")
}
case $F_target_distribution in
tools|tools*)
  if (( "$F_build" ))
  then
    add_pkg clfs root
    add_pkg cross root
    add_pkg cross env
    add_pkg tools root
  fi
  add_pkg tools2 root
  if (( "$F_build" ))
  then
    add_pkg tools env
    add_pkg tools linux-headers
  fi
  add_pkg tools2 linux-headers
  if (( "$F_build" ))
  then
    add_pkg cross file
    add_pkg cross m4
    for p in \
      file m4 \
      ncurses pkg-config-lite gmp mpfr mpc isl cloog \
      isl binutils gcc-static bc
    do
      add_pkg cross "$p"
    done
    add_pkg tools glibc
  fi
  add_pkg tools2 glibc
  if (( "$F_build" ))
  then
    add_pkg cross gcc
  fi
  for p in \
    gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check \
    coreutils \
    diffutils file findutils gawk gettext grep gzip make patch sed tar texinfo \
    util-linux xz bootscripts e2fsprogs kmod shadow sysvinit eudev linux grub \
    gcc-aliases bash-aliases coreutils-aliases grep-aliases file-aliases \
    sysvinit-aliases shadow-aliases linux-aliases linux-devices \
    linux-credentials linux-fstab-cd linux-fstab-hd linux-log-directories \
    bash-profile iproute2 dhcp dhcp-config dropbear dropbear-config nettle \
    libtasn1 gnutls \
    internal-ca-certificates wget rsync buildsystem linux-mountpoints busybox \
    initrd linux-firmware gigayak-installer stage2-certificate go-sget \
    buildsystem-config
  do
    if (( "$F_build" ))
    then
      add_pkg tools "$p"
    fi
    add_pkg tools2 "$p"
  done

  # Needed by all tools3 packages - can't be built by tools3, though.
  # TODO: Can it?  It's .bootstrap.sh style, so it doesn't depend on itself.
  add_pkg tools3 filesystem-skeleton
  
  if (( "$F_build" ))
  then
    # Needed for sget to work, but must be built on system on which
    # create_crypto.sh was run (for now).
    add_pkg yak enable-dynamic-ca-certificates
    add_pkg yak internal-ca-certificates
    add_pkg yak stage3-certificate
  
    # And no joke, we generate the tools version of the Mozilla CA certificate
    # package from the final version, rather than the other way around.  Either
    # could go first, I suppose, but yak-ca-certificates existed first, and
    # doing a full rebuild (to test the inversion) would take a long time (~40
    # hours) right now.  So you have this comment instead.
    #
    # Really should stop procrastinating on this...
    #
    # TODO: This could totally be cleaned up if someone has a few CPU-days for
    # testing purposes...
    add_pkg yak ca-certificates
    add_pkg tools ca-certificates
  fi
  add_pkg tools2 ca-certificates
  
  if (( "$F_build" ))
  then
    # The buildsystem config is just copied over from the host system, so we
    # copy it as close to the source as possible.  This prevents weird automated
    # config overrides made by the buildsystem from accidentally propagating
    # into the final image.
    add_pkg yak buildsystem-config
  fi
  ;;
yak)
  add_pkg yak filesystem-skeleton
  if (( "$F_install" ))
  then
    # yak packages built in stage1
    add_pkg yak enable-dynamic-ca-certificates
    add_pkg yak internal-ca-certificates
    add_pkg yak stage3-certificate
    add_pkg yak ca-certificates
    add_pkg yak buildsystem-config
  fi
  if (( "$F_build" ))
  then
    add_pkg tools3 tcl
    add_pkg tools3 expect
    add_pkg tools3 dejagnu
    add_pkg tools3 perl
    add_pkg tools3 texinfo
    add_pkg tools3 gdb
  fi
  add_pkg yak linux-headers
  add_pkg yak man-pages
  add_pkg yak glibc
  if (( "$F_build" ))
  then
    add_pkg tools3 gcc
    add_pkg tools3 gcc-aliases
  fi
  add_pkg yak m4
  add_pkg yak gmp
  add_pkg yak mpfr
  add_pkg yak mpc
  add_pkg yak isl
  add_pkg yak cloog
  add_pkg yak zlib
  add_pkg yak flex
  add_pkg yak bison
  add_pkg yak binutils
  add_pkg yak gcc
  add_pkg yak sed
  add_pkg yak pkg-config-lite
  add_pkg yak ncurses
  add_pkg yak shadow
  add_pkg yak util-linux
  add_pkg yak bzip2
  add_pkg yak coreutils
  add_pkg yak perl
  add_pkg yak autoconf
  add_pkg yak automake
  add_pkg yak gettext
  add_pkg yak e2fsprogs
  add_pkg yak libtool
  add_pkg yak procps-ng
  add_pkg yak iana-etc
  add_pkg yak iproute2
  add_pkg yak gdbm
  add_pkg yak readline
  add_pkg yak bash
  add_pkg yak bash-aliases
  add_pkg yak bash-config
  add_pkg yak bash-profile
  add_pkg yak bc
  add_pkg yak diffutils
  add_pkg yak file
  add_pkg yak gawk
  add_pkg yak findutils
  add_pkg yak grep
  add_pkg yak groff
  add_pkg yak less
  add_pkg yak gzip
  add_pkg yak iputils
  add_pkg yak kbd
  add_pkg yak libpipeline
  add_pkg yak man
  add_pkg yak make
  add_pkg yak xz
  add_pkg yak kmod
  add_pkg yak patch
  add_pkg yak psmisc
  add_pkg yak libestr
  add_pkg yak libee
  add_pkg yak debianutils
  add_pkg yak eventlog
  add_pkg yak libffi
  add_pkg yak python
  add_pkg yak glib
  add_pkg yak pcre
  add_pkg yak openssl
  add_pkg yak syslog-ng
  add_pkg yak sysvinit
  add_pkg yak sysvinit-config
  add_pkg yak tar
  add_pkg yak texinfo
  add_pkg yak eudev
  add_pkg yak vim
  add_pkg yak syslinux
  add_pkg yak dhcpcd
  add_pkg yak bootscripts
  add_pkg yak bootscripts-config
  add_pkg yak input-config
  add_pkg yak fstab-config
  add_pkg yak linux
  add_pkg yak linux-credentials
  add_pkg yak nettle
  add_pkg yak libtasn1
  add_pkg yak gnutls
  add_pkg yak wget
  add_pkg yak go14
  add_pkg yak go
  add_pkg yak asciidoc
  add_pkg yak curl
  add_pkg yak expat
  add_pkg yak tcl
  add_pkg yak git
  add_pkg yak go-sget
  add_pkg yak dropbear
  add_pkg yak dropbear-config
  add_pkg yak lxc
  add_pkg yak config-os-release-info
  add_pkg yak rsync
  add_pkg yak libmnl
  add_pkg yak libnftnl
  add_pkg yak iptables
  add_pkg yak bridge-utils
  add_pkg yak cgroupfs-mount
  add_pkg yak lvm
  add_pkg yak parted
  add_pkg yak buildsystem
  add_pkg yak gigayak-installer
  ;;
*)
  log_fatal "no idea how to create livemedia for $(sq "$F_target_distribution")"
  ;;
esac

for p in "${pkgs[@]}"
do
  echo "$p"
done
