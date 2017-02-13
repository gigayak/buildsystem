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
case $YAK_TARGET_ARCH in
i*86)
  export GOARCH=386
  lib=lib
  ldlinux="ld-linux.so.2"
  ;;
x86_64|amd64)
  export GOARCH=amd64
  lib=lib # lib64 in multilib
  # ld-linux.so.2 is ld-linux-x86-64.so.2 on 64-bit systems.  No idea why -
  # possibly some old pre-multilib cruft?  
  ldlinux="ld-linux-x86-64.so.2"
  ;;
*)
  echo "$(basename "$0"): unknown architecture '$YAK_TARGET_ARCH'" >&2
  exit 1
  ;;
esac
echo "${GOOS}-${GOARCH}" > "$YAK_WORKSPACE/go-bin-dirname"

cd "$YAK_WORKSPACE"
paths=()
paths+=("git.jgilik.com/sget")
paths+=("github.com/gigayak/sget")
url=""
import_path=""
for path in "${paths[@]}"
do
  if curl \
    --head \
    --fail \
    "https://$path" \
    >/dev/null
  then
    echo "Building from URL https://$path" >&2
    export url="https://$path"
    export import_path="$path"
    break
  else
    echo "Not considering URL https://$path" >&2
  fi
done
if [[ -z "$url" ]]
then
  echo "Failed to find import path for sget" >&2
  exit 1
fi

mkdir -pv workspace/{src,bin,pkg}
cd workspace
export GOPATH="$PWD"

go get -v -d -t "$import_path/..."

export CC="$CC_FOR_TARGET"
export CXX="$CXX_FOR_TARGET"
# The --ldflags parameter sets flags for Go's linker.
# They are described here:
#   https://golang.org/cmd/link/
# -I /tools/ARCH/lib/ld-linux.so.2 ensures it uses the correct dependency
#   interpreter - as the standard one at /lib/ld-linux.so.2 is not
#   available in the stage2 image.
# -extld $LD ensures use of the cross-compilation toolchain's linker.  This
#   may be redundant.
go install \
  --ldflags "-I /tools/${YAK_TARGET_ARCH}/$lib/$ldlinux -extld $LD" \
  -v \
  ./...

