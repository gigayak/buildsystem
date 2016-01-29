#!/bin/bash
set -Eeo pipefail

# Default to assuming hardware clock is set to UTC.
# (Not aiming at supporting dual boot yet.)
echo UTC=1 > /etc/sysconfig/clock

# Default hostname.
echo HOSTNAME=yak > /etc/sysconfig/network

# Default first interface to DHCP.
mkdir -pv /etc/sysconfig/network-devices/ifconfig.eth0
cat > /etc/sysconfig/network-devices/ifconfig.eth0/dhcpcd <<'EOF'
ONBOOT="yes"
SERVICE="dhcpcd"

# Start Command for DHCPCD
DHCP_START="-q"

# Stop Command for DHCPCD
DHCP_STOP="-k"
EOF
