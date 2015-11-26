#!/bin/bash
set -Eeo pipefail

# Ensure user exists
# TODO: Should there be a default unprivileged user in our images?
# For now, all the things are root.  For shame.

# Create the database.  Pre-create the file, so that the user can play with it.
# This gets around patching Gitzebo directly for the moment.
src_paths=()
src_paths+=("/usr/lib/python2.7/site-packages/gitzebo")
src_paths+=("/usr/local/lib/python2.7/dist-packages/gitzebo")
src_path=""
for path in "${src_paths[@]}"
do
  if [[ -d "$path" ]]
  then
    src_path="$path"
    break
  fi
done
if [[ -z "$src_path" ]]
then
  echo "Unable to locate Gitzebo installation path." >&2
  exit 1
fi
src_db="$src_path/gitzebo.db"
tgt_db="/opt/db/gitzebo.db"
ln -s "$tgt_db" "$src_db"

# Create the directory to hold SSH information in.
mkdir -pv /root/.ssh
chmod 0700 /root/.ssh

# Create "privilege separation directory" if it doesn't exist yet.
# sshd doesn't like to start without this...
if [[ ! -d "/var/run/sshd" ]]
then
  mkdir -p "/var/run/sshd"
fi

# Create links for persistent configuration files.
# TODO: disabled due to hack below
#ln -s {/opt/db,/root/.ssh}/authorized_keys
keys=()
keys+=(ssh_host_key ssh_host_key.pub)
keys+=(ssh_host_rsa_key ssh_host_rsa_key.pub)
keys+=(ssh_host_dsa_key ssh_host_dsa_key.pub)
keys+=(ssh_host_ecdsa_key ssh_host_ecdsa_key.pub)
keys+=(ssh_random_seed)
for key in "${keys[@]}"
do
  if [[ -e "/etc/ssh/$key" ]]
  then
    rm -fv "/etc/ssh/$key"
  fi
  ln -sv {/opt/db,/etc/ssh}/"$key"
done
# TODO: ensure these keys are generated

# This script periodically refreshes repository information to generate static
# pack files.  This should not be necessary in a version with a smarter HTTPS
# server.
# TODO: ensure HTTPS server generates packfiles automatically in Go version.
cat > /usr/bin/regenerate_packs <<'EOF'
#!/bin/bash
set -Eeo pipefail
while true
do
  while read -r repo
  do
    cd "$repo" \
      && git update-server-info \
      || \
    {
      echo "Failed to update repo '$repo'" >&2
      continue
    }
    echo \
      "<meta name=\"go-import\" " \
        "content=\"git.jgilik.com/$(basename "$repo" .git) git" \
          "https://git.jgilik.com/$(basename "$repo")/\" />" \
      > "$(dirname "$repo")/$(basename "$repo" .git)" \
    || \
    {
      echo "Failed to create metadata file for repo '$repo'" >&2
      continue
    }
  done < <(find /opt/git -mindepth 1 -maxdepth 1 -type d)
  sleep 15
done
EOF
chmod +x /usr/bin/regenerate_packs

# TODO: We don't yet have a user for unprivileged stuff, and SSHD wants one.
# This disables the sandboxing that results in this requirement at the cost of
# security - but should be okay for a little while.
cp -v /etc/ssh/sshd_config{,.gitzebo}
echo 'UsePrivilegeSeparation no' >> /etc/ssh/sshd_config.gitzebo

cat > /usr/bin/container.init <<'EOF'
#!/bin/bash
set -Eeo pipefail
export HOME=/root
for profile in .bash_profile .profile .bashrc
do
  if [[ -e "$HOME/$profile" ]]
  then
    echo "$(basename "$0"): importing profile '$profile'" >&2
    source "$HOME/$profile"
  fi
done
# If PATH is not exported, then PATH-based lookups in gitzebo-regenerate-keys
# will throw exceptions on Ubuntu.  This likely has to do with the session
# appearing to be non-interactive, and some other workaround likely exists...
export PATH

repo_dir=/opt/git
if [[ ! -e "$repo_dir" ]]
then
  echo "$(basename "$0"): repository directory '$repo_dir' does not exist" >&2
  exit 1
fi
db_dir=/opt/db
if [[ ! -e "$db_dir" ]]
then
  echo "$(basename "$0"): database directory '$db_dir' does not exist" >&2
  exit 1
fi
db="$db_dir/gitzebo.db"
if [[ ! -e "$db" ]]
then
  echo "$(basename "$0"): recreating databse '$db'" >&2
  gitzebo-schema create
fi


# TODO: HACK HACK HACK We need /root/.ssh/ to keep key data around.
#       pkg.sh excludes /root from consideration for packaging, because
#       it may contain transient data.  :[
if [[ ! -d "/root/.ssh" ]]
then
  mkdir -pv /root/.ssh
  chmod 0700 /root/.ssh
fi
if [[ ! -L "/root/.ssh/authorized_keys" ]]
then
  ln -s {/opt/db,/root/.ssh}/authorized_keys
fi

stop_all()
{
  kill -SIGTERM "$web_pid"
  /etc/init.d/sshd stop
  kill -SIGTERM "$regen_pid"
  kill -SIGTERM "$ssl_pid"
}
term_handler()
{
  echo "$(basename "$0"): caught SIGTERM, shutting down" >&2
  stop_all
}
echo "$(basename "$0"): enabling SIGTERM handler" >&2
trap term_handler 15
err_handler()
{
  echo "$(basename "$0"): error occurred in the main thread, shutting down." >&2
  stop_all
}
echo "$(basename "$0"): enabling EXIT/ERR handler" >&2
trap err_handler EXIT ERR

echo "$(basename "$0"): regenerating key file" >&2
gitzebo-regenerate-keyfile

echo "$(basename "$0"): starting sshd" >&2
/usr/sbin/sshd -D -e -f /etc/ssh/sshd_config.gitzebo &
ssh_pid="$!"
echo "$(basename "$0"): sshd running on PID $ssh_pid" >&2

echo "$(basename "$0"): starting frontend" >&2
gitzebo-dev-server &
web_pid="$!"
echo "$(basename "$0"): frontend started with PID $web_pid" >&2

echo "$(basename "$0"): starting git-over-HTTPS server" >&2
https-fileserver \
  --key=/opt/db/git.key \
  --certificate=/opt/db/git.crt \
  --dir=/opt/git &
ssl_pid="$!"
echo "$(basename "$0"): git-over-HTTPS server started with PID $ssl_pid" >&2

echo "$(basename "$0"): starting pack regenerator" >&2
/usr/bin/regenerate_packs &
regen_pid="$!"
echo "$(basename "$0"): pack regenerator started with PID $regen_pid" >&2

toret=0
retval=0
wait "$web_pid" || retval=$?
echo "$(basename "$0"): frontend exited with code $retval" >&2
(( "$retval" )) && toret=$retval
wait "$regen_pid" || retval=$?
echo "$(basename "$0"): pack regenerator exited with code $retval" >&2
(( "$retval" )) && toret=$retval
wait "$ssl_pid" || retval=$?
echo "$(basename "$0"): git-over-HTTPS server exited with code $retval" >&2
(( "$retval" )) && toret=$retval
wait "$ssh_pid" || retval=$?
echo "$(basename "$0"): sshd exited with code $retval" >&2
(( "$retval" )) && toret=$retval
exit "$toret"
EOF
chmod +x /usr/bin/container.init

mkdir /opt/git
mkdir /opt/db
cat > /etc/container.mounts <<EOF
repo /opt/git
db /opt/db
EOF

