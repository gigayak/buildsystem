#!/bin/bash
set -Eeo pipefail

ip="$(ip a | grep inet | grep -v inet6 | grep -v '127.0.0.1' | awk '{print $2}' | sed -nre 's@^([0-9.]+)/.*$@\1@gp' | head -1)"

cat > /etc/yum.repos.d/jpg.repo <<EOF
[jpg]
name=JPG Custom RPM Repository
baseurl=http://$ip/repo
enabled=1
priority=1
EOF

