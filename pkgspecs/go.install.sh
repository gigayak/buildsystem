#!/bin/bash
set -e
set -E
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make sure base directories exist
mkdir -p "/usr"
mkdir -p "/etc/profile.d"

# copy package
cp -r "go" "/usr/go"

# create PATH script for bash
# TODO: csh?
cat > "/etc/profile.d/go.sh" <<'EOF'
# go initialization
if [ -z "$GOROOT" ]
then
  export GOROOT="/usr/go"
  export PATH="$PATH:/usr/go/bin"
fi
EOF

# run tests
cd "/usr/go/src"
export GOROOT="/usr/go"
export GOROOT_FINAL="/usr/go"
export PATH="$PATH:/usr/go/bin"
bash run.bash --no-rebuild 2>&1 \
  | tee /root/test.log

# exclude failing tests from consideration
# TestParseInSydney in 1.3.3; TODO: remove in 1.4
# er, it might be fixed in 1.3.3?
# TestHostname fails due to missing /bin/hostname
( \
grep FAIL /root/test.log \
  | grep -v TestHostname \
  || true \
) > /root/failures.log

if (( "$(wc -l /root/failures.log)" > 0 ))
then
  echo "Test failures:"
  cat /root/failures.log
  exit 1
fi
