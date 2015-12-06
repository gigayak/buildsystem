#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

export CC_FOR_TARGET="$CC"
export CXX_FOR_TARGET="$CXX"
export CC="gcc"
export CGO_ENABLED=1
export GOROOT=/usr/go
export PATH="$PATH:/usr/go/bin"
export GOROOT_BOOTSTRAP=/usr/go14
export GOOS=linux
export GOARCH=386

cd /usr/go/src
bash make.bash --no-banner

cd /root
mkdir -pv workspace/{bin,pkg,src/git.jgilik.com}
cd workspace/src/git.jgilik.com
git clone https://git.jgilik.com/sget.git

export GOPATH=/root/workspace
export CC="$CC_FOR_TARGET"
export CXX="$CXX_FOR_TARGET"
# The --ldflags parameter sets flags for Go's linker.
# They are described here:
#   https://golang.org/cmd/link/
# -I /tools/i686/lib/ld-linux.so.2 ensures it uses the correct dependency
#   interpreter - as the standard one at /lib/ld-linux.so.2 is not
#   available in the stage2 image.
# -extld $LD ensures use of the cross-compilation toolchain's linker.  This
#   may be redundant.
go install \
  --ldflags "-I /tools/i686/lib/ld-linux.so.2 -extld $LD" \
  -v \
  ./...

