#!/bin/bash
set -Eeo pipefail

# Ensure directory to hold keys exists.
mkdir -pv "/etc/dropbear"

# Build an initscript that ups dropbear (and generates keys if needed).
cat > "/etc/rc.d/init.d/dropbear" <<'EOF'
#!/bin/bash
set -Eeo pipefail

key_dir="/etc/dropbear"

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
chmod +x "/etc/rc.d/init.d/dropbear"
ln -sv ../init.d/dropbear "/etc/rc.d/rc3.d/S20dropbear"

# HACK: Override old symlink from tools-dropbear-config
# (This prevents accidentally packaging to /tools/i686/etc/shells.)
rm -f /etc/shells

# HACK: Need a valid shell for dropbear to use for root user...
cat > "/etc/shells" <<'EOF'
/bin/sh
/bin/bash
EOF
