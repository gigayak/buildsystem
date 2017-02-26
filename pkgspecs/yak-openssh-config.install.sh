#!/bin/bash
set -Eeo pipefail

cat > "/etc/rc.d/init.d/openssh" <<'EOF'
#!/bin/bash
set -Eeo pipefail

/usr/sbin/sshd
EOF
chmod +x "/etc/rc.d/init.d/openssh"
ln -sv ../init.d/openssh "/etc/rc.d/rc3.d/S20openssh"

# Remove shells symlink in the event that tools-* has created one, which would
# cause writes to be directed incorrectly.
rm -f /etc/shells

# Correct /etc/shells configuration.
# TODO: Move this to a more central package.
cat > "/etc/shells" <<'EOF'
/bin/sh
/bin/bash
EOF
