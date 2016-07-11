#!/bin/bash
set -Eeo pipefail

source "$YAK_BUILDSYSTEM/config.sh"
source "$YAK_BUILDSYSTEM/escape.sh"
domain="$(sq "$(get_config DOMAIN)")"

cat > /etc/container.mounts <<EOF
ssl /opt/ssl
EOF

cat > /usr/bin/container.init <<EOF
#!/bin/bash
set -Eeo pipefail

/usr/bin/proxy \
  --domain=$domain \
  --key=/opt/ssl/proxy.key \
  --certificate=/opt/ssl/proxy.crt \
  --certificate_authority="/etc/pki/ca-trust/source/anchors/gigayak.pem,/usr/local/share/ca-certificates/gigayak.pem,/etc/ssl/certs/gigayak.pem"
EOF
chmod +x /usr/bin/container.init
