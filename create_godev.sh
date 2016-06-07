#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/flag.sh"
source "$(DIR)/mkroot.sh"
source "$(DIR)/cleanup.sh"
source "$(DIR)/log.sh"
add_flag --required pkg_name "Name of Go package to create environment for."
parse_flags "$@"

# Strip go- prefix if it was given.
# This may cause odd behaviors if we name a package go-go-power-rangers...
pkg_name="$(echo "$F_pkg_name" | sed -re 's@^go-@@')"
log_rote "preparing environment for $pkg_name"

mkroot root

deps=()
# Needed to compile:
deps+=(go gcc)
# Needed to download source:
deps+=(git openssh-clients)
# Needed to authenticate git server for download:
deps+=(internal-ca-certificates)
# Needed for root user to be usable:
deps+=(filesystem-skeleton)
# Needed to actually horse around with Go code:
deps+=(vim vim-pathogen vim-pathogen-config vim-go)
for dep in "${deps[@]}"
do
  "$(DIR)/install_pkg.sh" \
    --install_root="$root" \
    --pkg_name="$dep"
done

# Set up directory tree outside of chroot to transfer data in.
# ($pkg_name is not propagated across chroot by default.)
mkdir -pv "$root/root/workspace"
echo "$pkg_name" > "$root/root/workspace/.pkg_name"

# Ensure the godev SSH key is present.
# TODO: Key distribution should somehow be centralized and ACLed.
mkdir -pv "$root/root/.ssh"
chmod 0700 "$root/root/.ssh"
"$(DIR)/get_crypto.sh" \
  --private \
  --key_name=godev \
  --key_type=rsa \
  > "$root/root/.ssh/id_rsa"
chmod 0600 "$root/root/.ssh/id_rsa"
"$(DIR)/get_crypto.sh" \
  --public \
  --key_name=godev \
  --key_type=rsa \
  > "$root/root/.ssh/id_rsa.pub"
chmod 0644 "$root/root/.ssh/id_rsa.pub"
for type in rsa dsa
do
  "$(DIR)/get_crypto.sh" \
    --key_name=gitzebo \
    --key_type="$type" \
    --public \
  | sed -re 's@^@git.jgilik.com @g' \
  >> "$root/root/.ssh/known_hosts"
done
chmod 0644 "$root/root/.ssh/known_hosts"

# Build workspace and package so that we're all ready to rock.
chroot "$root" /bin/bash <<'EOF_CHROOT'
#!/bin/bash
set -Eeo pipefail
source /etc/profile.d/go.sh

# Set up git details
git config --global user.name "John Gilik"
git config --global user.email "john@jgilik.com"

export pkg_name="$(</root/workspace/.pkg_name)"
export IMPORT_PATH="git.jgilik.com/$pkg_name"

cd /root/workspace
export GOPATH="$PWD"
mkdir -pv src bin pkg

# TODO: Make sure this pulls package correctly.
# TODO: Make sure remote is set correctly.
mkdir -pv "src/git.jgilik.com"
cd "src/git.jgilik.com"
git clone root@git.jgilik.com:$pkg_name.git
cd "$GOPATH/src"

# We want to be able to check out the directory at this point, as source exists.
# Since we can't disable cleanup within a chroot, we can just force a return
# code of zero to ensure we don't choke if the build fails.
trap 'exit 0' EXIT ERR

# We probably want to make sure that the environment builds the program quickly
# when it finally does come up...
go get -v -d -t "./..."
go install -v "./..."
EOF_CHROOT

# Make sure root logs in directly into the workspace.
cat > "$root/etc/profile.d/go-workspace.sh" <<EOF_WORKSPACE
#!/bin/bash
export GOPATH="/root/workspace"
export PATH="\$PATH:/root/workspace/bin"
export EDITOR="vim"
alias vi=vim
cd "/root/workspace/src/git.jgilik.com/$pkg_name"
EOF_WORKSPACE

dont_depopulate_dynamic_fs_pieces "$root"
unregister_temp_file "$root"
echo "godev chroot available at $root"
