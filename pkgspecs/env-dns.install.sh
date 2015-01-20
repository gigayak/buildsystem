#!/bin/bash
set -Eeo pipefail

cat > /etc/dnsmasq.d/permanent-conf.conf <<'EOF'
conf-dir=/opt/dns
EOF

cat > /etc/container.mounts <<EOF
dns /opt/dns
EOF

cat > /usr/bin/container.init <<EOF
#!/bin/bash
set -Eeo pipefail

/usr/sbin/dnsmasq \
  --keep-in-foreground \
  --conf-dir=/opt/dns
EOF
chmod +x /usr/bin/container.init
