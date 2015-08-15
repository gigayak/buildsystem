#!/bin/bash
set -Eeo pipefail

cat > /etc/container.mounts <<EOF
www /opt/www
ssl /opt/ssl
EOF

cat > /usr/bin/container.init <<EOF
#!/bin/bash
set -Eeo pipefail

/usr/bin/https-fileserver \
  --dir=/opt/www \
  --key=/opt/ssl/www.key \
  --certificate=/opt/ssl/www.crt
EOF
chmod +x /usr/bin/container.init
