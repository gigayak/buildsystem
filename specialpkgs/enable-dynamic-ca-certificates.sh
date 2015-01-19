#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$DIR/.." && pwd )"

source "$ROOT/arch.sh"
source "$ROOT/mkroot.sh"
source "$ROOT/escape.sh"

source=empty
pkgname="$(basename "$0" .sh)"
pkgversion=1.0
arch="$(architecture)"

make_temp_dir tmpscripts
cat > "$tmpscripts/postinstall.sh" <<'EOF'
update-ca-trust enable
EOF

make_temp_dir tmprepo
fpm \
  -t rpm \
  -s "$source" \
  -n "$pkgname" \
  -v "$pkgversion" \
  -p "$tmprepo/$pkgname-$pkgversion-1.$arch.rpm" \
  --after-install "$tmpscripts/postinstall.sh" \
  --depends "ca-certificates"
mv -v "$tmprepo/"* /var/www/html/repo/
createrepo --update /var/www/html/repo/
