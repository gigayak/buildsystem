#!/bin/bash
set -Eeo pipefail

cat > /etc/container.mounts <<EOF
ssl /opt/ssl
EOF

cat > /usr/bin/container.init <<EOF
#!/bin/bash
set -Eeo pipefail

/usr/bin/proxy \
  --domain=jgilik.com \
  --key=/opt/ssl/proxy.key \
  --certificate=/opt/ssl/proxy.crt
EOF
chmod +x /usr/bin/container.init
