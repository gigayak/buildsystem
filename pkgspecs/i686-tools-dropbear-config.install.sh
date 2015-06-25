#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# This would actually fail in a cross-compiled setting :o
# TODO: Move this into an initscript
#"$CLFS/tools/i686/bin/dropbearkey" \
#  -t rsa \
#  -s 1024 \
#  -f "$CLFS/tools/i686/etc/dropbear_rsa_host_key"
# Ensure directory to hold keys exists.
mkdir -pv "$CLFS/tools/i686/etc/dropbear"

# Build an initscript that ups the network interface.
cat > "$CLFS/tools/i686/etc/rc.d/init.d/eth0" <<'EOF'
#!/bin/bash
set -Eeo pipefail
if [[ "$1" != "start" ]]
then
  echo "This script is dumb and can only start."
  exit 0
fi

for binary in ip dhclient
do
  for bindir in /bin /usr/bin /sbin /usr/sbin /tools/i686/bin /tools/i686/sbin
  do
    if [[ ! -e "$bindir/$binary" ]]
    then
      continue
    fi
    export "$binary"="$bindir/$binary"
  done
  if [[ -z "${!binary}" ]]
  then
    echo "Failed to find binary $binary." >&2
    exit 1
  fi
done

echo "Starting eth0"
${ip} link set eth0 up
${dhclient} -v eth0
EOF
chmod +x "$CLFS/tools/i686/etc/rc.d/init.d/eth0"
ln -sv ../init.d/eth0 "$CLFS/tools/i686/etc/rc.d/rcsysinit.d/S70eth0"

# Build an initscript that ups dropbear (and generates keys if needed).
cat > "$CLFS/tools/i686/etc/rc.d/init.d/dropbear" <<'EOF'
#!/bin/bash
set -Eeo pipefail

# List of directories to attempt finding keys in.
#
# If no keys are found, then it's the list of paths to attempt
# writing keys to.
#
# Paths are evaluated in the order they're added to the array.
#
# HACK SCALE: PUNY
#
# This feature exists solely to allow Dropbear to work when
# booting from a live CD, where /tools/i686/etc/dropbear is not
# writable.  We could avoid this if we used a union filesystem
# which allows COW-to-memory writes to the read-only image, but
# this would require kernel changes.  This hack works with a
# stock kernel juuuust fine.
key_dirs=()
key_dirs+=("/tools/i686/etc/dropbear")
key_dirs+=("/tmp")

keys=(rsa_host_key)

found=0
for key_dir in "${key_dirs[@]}"
do
  for key in "${keys[@]}"
  do
    if [[ -e "$key_dir/$key" ]]
    then
      found=1
      break
    fi
  done
done
if (( ! "$found" ))
then
  for key_dir in "${key_dirs[@]}"
  do
    if [[ -w "$key_dir" ]]
    then
      found=1
      break
    fi
  done
fi
if (( ! "$found" ))
then
  echo "Unable to find viable directory to store host keys in." >&2
  exit 1
fi

rsa_key="$key_dir/rsa_host_key"
if [[ ! -e "$rsa_key" ]]
then
  dropbearkey -t rsa -s 1024 -f "$rsa_key"
fi
# -B: allow blank password to login (say, for root)
# -K <arg>: keepalive every <arg> seconds
# -I <arg>: disconnect clients after <arg> seconds of idle time
#   (0 disables both -K and -I)
# -r <arg>: read RSA host key from <arg>
# -E: log to stderr instead of syslog
dropbear -B -K 60 -I 3600 -r "$rsa_key" -E
EOF
chmod +x "$CLFS/tools/i686/etc/rc.d/init.d/dropbear"
ln -sv ../init.d/dropbear "$CLFS/tools/i686/etc/rc.d/rc3.d/S20dropbear"

# HACK: Need a valid shell for dropbear to use for root user...
cat > "$CLFS/tools/i686/etc/shells" <<'EOF'
/bin/sh
/bin/bash
EOF
ln -sv /tools/i686/etc/shells "$CLFS/etc/shells"
