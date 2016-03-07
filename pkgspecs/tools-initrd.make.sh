#!/bin/bash
set -Eeo pipefail

mkdir -pv "$YAK_WORKSPACE/initrd"
for p in root busybox eudev
do
  /usr/bin/buildsystem/install_pkg.sh \
    --install_root="$YAK_WORKSPACE/initrd" \
    --target_architecture="$YAK_TARGET_ARCH" \
    --target_distribution=tools2 \
    --pkg_name="$p"
done

# This is the initscript provided by the LFS book.
cat > "$YAK_WORKSPACE/initrd/init" <<EOF
#!/tools/$YAK_TARGET_ARCH/bin/sh
PATH=/bin:/usr/bin:/tools/$YAK_TARGET_ARCH/bin:/tools/$YAK_TARGET_ARCH/usr/bin:/sbin:/usr/sbin:/tools/$YAK_TARGET_ARCH/sbin:/tools/$YAK_TARGET_ARCH/usr/sbin
export PATH


problem()
{
   printf "Encountered a problem!\\n\\nDropping you to a shell.\\n\\n"
   sh
}

no_device()
{
   printf "The device %s, which is supposed to contain the\\n" \$1
   printf "root file system, does not exist.\\n"
   printf "Please fix this problem and exit this shell.\\n\\n"
}

no_mount()
{
   printf "Could not mount device %s\\n" \$1
   printf "Sleeping forever. Please reboot and fix the kernel command line.\\n\\n"
   printf "Maybe the device is formatted with an unsupported file system?\\n\\n"
   printf "Or maybe filesystem type autodetection went wrong, in which case\\n"
   printf "you should add the rootfstype=... parameter to the kernel command line.\\n\\n"
   printf "Available partitions:\\n"
}

do_mount_root()
{
   mkdir /.root
   [ -n "\$rootflags" ] && rootflags="\$rootflags,"
   rootflags="\$rootflags\$ro"

   case "\$root" in
      /dev/* ) device=\$root ;;
      UUID=* ) eval \$root; device="/dev/disk/by-uuid/\$UUID"  ;;
      LABEL=*) eval \$root; device="/dev/disk/by-label/\$LABEL" ;;
      ""     ) echo "No root device specified." ; problem    ;;
   esac

   if [ ! -b "\$device" ] ; then
      echo "Waiting 5s for \$device to be available."
      sleep 5
   fi
   while [ ! -b "\$device" ] ; do
       no_device \$device
       problem
   done

   if ! mount -n -t "\$rootfstype" -o "\$rootflags" "\$device" /.root ; then
       no_mount \$device
       cat /proc/partitions
       while true ; do sleep 10000 ; done
   else
       echo "Successfully mounted device \$root"
   fi
}

init=/sbin/init
root=
rootdelay=
rootfstype=auto
ro="ro"
rootflags=
device=

mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc     proc     /proc
mount -n -t sysfs    sysfs    /sys
mount -n -t tmpfs    tmpfs    /run

read -r cmdline < /proc/cmdline

for param in \$cmdline ; do
  case \$param in
    init=*      ) init=\${param#init=}             ;;
    root=*      ) root=\${param#root=}             ;;
    rootdelay=* ) rootdelay=\${param#rootdelay=}   ;;
    rootfstype=*) rootfstype=\${param#rootfstype=} ;;
    rootflags=* ) rootflags=\${param#rootflags=}   ;;
    ro          ) ro="ro"                         ;;
    rw          ) ro="rw"                         ;;
  esac
done

if [ "\$root" == "DEBUG=DEBUG" ]
then
  exec /tools/$YAK_TARGET_ARCH/bin/sh
fi

# udevd location depends on version
if [ -x /sbin/udevd ]; then
  UDEVD=/sbin/udevd
elif [ -x /lib/udev/udevd ]; then
  UDEVD=/lib/udev/udevd
elif [ -x /lib/systemd/systemd-udevd ]; then
  UDEVD=/lib/systemd/systemd-udevd
elif [ -x /tools/i686/sbin/udevd ]; then
  UDEVD=/tools/i686/sbin/udevd
elif [ -x /tools/i686/lib/udev/udevd ]; then
  UDEVD=/tools/i686/lib/udev/udevd
else
  echo "Cannot find udevd nor systemd-udevd"
  problem
fi

\${UDEVD} --daemon --resolve-names=never
udevadm trigger
udevadm settle

if [ -f /etc/mdadm.conf ] ; then mdadm -As                       ; fi
if [ -x /sbin/vgchange  ] ; then /sbin/vgchange -a y > /dev/null ; fi
if [ -n "\$rootdelay"    ] ; then sleep "\$rootdelay"              ; fi

do_mount_root

# We don't have killall -w available (which waits for all processes
# to finish dying) - so we can emulate it by waiting until killall
# chucks a fit, which it does when no processes match the pattern.
while killall \${UDEVD##*/}
do
  sleep 1
done

exec switch_root /.root "\$init" "\$@"
EOF
# Without the +x, you can get cryptic kernel hangs stemming from not
# a valid init.
chmod +x "$YAK_WORKSPACE/initrd/init"

# Since our rootfs is read-only in the live CD case, we're going to
# need ALL mount points pre populated - or to have a parent mounted
# read-write.
mkdir -pv "$YAK_WORKSPACE/initrd"/{proc,sys,run}

# Compress initrd / initramfs image.
#
# (Technically, this is an initramfs, but a lot of places may refer
# to it as initrd.)
(
  cd "$YAK_WORKSPACE"/initrd
  find . \
    | cpio -o -H newc --quiet \
    | gzip -9
) \
> "$YAK_WORKSPACE/initrd.igz"

