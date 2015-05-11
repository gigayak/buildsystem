#!/bin/bash
set -Eeo pipefail

cat > /etc/container.mounts <<EOF
repo /opt/repo
ssl /opt/ssl
EOF

cat > /usr/bin/container.init <<EOF
#!/bin/bash
set -Eeo pipefail

/usr/bin/https-fileserver \
  --dir=/opt/repo \
  --key=/opt/ssl/repo.key \
  --certificate=/opt/ssl/repo.crt
EOF
chmod +x /usr/bin/container.init
