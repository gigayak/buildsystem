#!/bin/bash
set -Eeo pipefail

# Ensure user exists
# TODO: Should there be a default unprivileged user in our images?
# For now, all the things are root.  For shame.

# Create the database.  Pre-create the file, so that the user can play with it.
# This gets around patching Gitzebo directly for the moment.
src_db="/usr/lib/python2.6/site-packages/gitzebo/gitzebo.db"
tgt_db="/opt/db/gitzebo.db"
ln -s "$tgt_db" "$src_db"

# Create the directory to hold SSH information in.
mkdir -pv /root/.ssh
chmod 0700 /root/.ssh

# Create links for persistent configuration files.
# TODO: disabled due to hack below
#ln -s {/opt/db,/root/.ssh}/authorized_keys
ln -s {/opt/db,/etc/ssh}/ssh_host_key
ln -s {/opt/db,/etc/ssh}/ssh_host_key.pub
ln -s {/opt/db,/etc/ssh}/ssh_host_rsa_key
ln -s {/opt/db,/etc/ssh}/ssh_host_rsa_key.pub
ln -s {/opt/db,/etc/ssh}/ssh_host_dsa_key
ln -s {/opt/db,/etc/ssh}/ssh_host_dsa_key.pub
# TODO: ensure these keys are generated
ln -s {/opt/db,/etc/ssh}/ssh_random_seed

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
source "$HOME/.bash_profile"

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
  kill -SIGTERM "$admin_pid"
  /etc/init.d/sshd stop
  kill -SIGTERM "$regen_pid"
  kill -SIGTERM "$ssl_pid"
}
term_handler()
{
  echo "Caught SIGTERM, shutting down"
  stop_all
}
trap term_handler 15
err_handler()
{
  echo "Something went wrong in the main thread, shutting down."
  stop_all
}
trap err_handler EXIT ERR

gitzebo-regenerate-keyfile

/usr/sbin/sshd -D -e -f /etc/ssh/sshd_config.gitzebo &
ssh_pid="$!"
echo "SSH running on PID $ssh_pid"

gitzebo-dev-server &
admin_pid="$!"
echo "Gitzebo frontend started with PID $admin_pid"

https-fileserver \
  --key=/opt/db/git.key \
  --certificate=/opt/db/git.crt \
  --dir=/opt/git &
web_pid="$!"
echo "Web server started with PID $web_pid"

/usr/bin/regenerate_packs &
regen_pid="$!"
echo "Pack regenerator started with PID $regen_pid"

/usr/bin/git-https-server &
ssl_pid="$!"
echo "HTTPS server started with PID $ssl_pid"

toret=0
retval=0
wait "$web_pid" || retval=$?
echo "Web server exited with return code $retval"
(( "$retval" )) && toret=$retval
wait "$regen_pid" || retval=$?
echo "Pack regenerator exited with return code $retval"
(( "$retval" )) && toret=$retval
wait "$ssl_pid" || retval=$?
echo "HTTPS server exited with return code $retval"
(( "$retval" )) && toret=$retval
wait "$ssh_pid" || retval=$?
echo "SSH server exited with return code $retval"
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

