#!/bin/bash
set -Eeo pipefail

# force-enable is because there's some sort of integration with RPM to detect
# if the ca-certificates package is installed or not.  Of course, since we no
# longer use RPM... that incorrectly reports that it's not installed.
update-ca-trust force-enable
