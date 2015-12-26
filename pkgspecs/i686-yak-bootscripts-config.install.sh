#!/bin/bash
set -Eeo pipefail

# Default to assuming hardware clock is set to UTC.
# (Not aiming at supporting dual boot yet.)
echo UTC=1 > /etc/sysconfig/clock

