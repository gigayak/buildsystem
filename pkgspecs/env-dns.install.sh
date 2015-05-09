#!/bin/bash
set -Eeo pipefail

cat > /etc/container.mounts <<EOF
dns /opt/dns
EOF

cat > /usr/bin/container.init <<EOF
#!/bin/bash
set -Eeo pipefail

/usr/sbin/dnsmasq \
  --log-facility=- \
  --conf-dir='/opt/dns,*.conf' \
  --keep-in-foreground
EOF
chmod +x /usr/bin/container.init
