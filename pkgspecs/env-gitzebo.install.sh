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


term_handler()
{
  echo "Caught SIGTERM, shutting down"
  if [[ ! -z "$pid" ]]
  then
    echo "Sending SIGTERM to $pid"
    kill -SIGTERM "$web_pid"
    /etc/init.d/sshd stop
  fi
}
trap term_handler 15

gitzebo-regenerate-keyfile

/usr/sbin/sshd -D -e &
ssh_pid="$!"
echo "SSH running on PID $ssh_pid"

gitzebo-dev-server &
web_pid="$!"
echo "Web server started with PID $web_pid"

toret=0
retval=0
wait "$web_pid" || retval=$?
echo "Web server exited with return code $retval"
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

