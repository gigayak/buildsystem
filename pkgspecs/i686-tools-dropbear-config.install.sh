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
rsa_key=/tools/i686/etc/dropbear/rsa_host_key
if [[ ! -e "$rsa_key" ]]
then
  dropbearkey -t rsa -s 1024 -f "$rsa_key"
fi
dropbear -B -K 15 -I 120 -r "$rsa_key"
EOF
chmod +x "$CLFS/tools/i686/etc/rc.d/init.d/dropbear"
ln -sv ../init.d/dropbear "$CLFS/tools/i686/etc/rc.d/rc3.d/S20dropbear"

# HACK: Need a valid shell for dropbear to use for root user...
cat > "$CLFS/tools/i686/etc/shells" <<'EOF'
/bin/sh
/bin/bash
EOF
ln -sv /tools/i686/etc/shells "$CLFS/etc/shells"
