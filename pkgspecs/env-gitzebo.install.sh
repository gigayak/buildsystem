#!/bin/bash
set -Eeo pipefail

# Ensure user exists
# TODO: Should there be a default unprivileged user in our images?
# For now, all the things are root.  For shame.

# Create the database.  Pre-create the file, so that the user can play with it.
# This gets around patching Gitzebo directly for the moment.
#gitzebo-schema create
src_db="/usr/lib/python2.6/site-packages/gitzebo/gitzebo.db"
tgt_db="/opt/db/gitzebo.db"
#mkdir -p "$tgt_db"
#mv "$src_db" "$tgt_db"
ln -s "$tgt_db" "$src_db"
#touch "$db"
#chown git: "$db"

#ln -s /usr/bin/gitzebo-dev-server /usr/bin/container.init
cat > /usr/bin/container.init <<'EOF'
#!/bin/bash
set -Eeo pipefail
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


term_handler()
{
  echo "Caught SIGTERM, shutting down"
  if [[ ! -z "$pid" ]]
  then
    echo "Sending SIGTERM to $pid"
    kill -SIGTERM "$pid"
  fi
}
trap term_handler 15
gitzebo-dev-server &
pid="$!"
echo "Server started with PID $pid"
retval=0
wait "$pid" || retval=$?
echo "Server exited with return code $retval"
exit "$retval"
EOF
chmod +x /usr/bin/container.init

mkdir /opt/git
mkdir /opt/db
cat > /etc/container.mounts <<EOF
repo /opt/git
db /opt/db
EOF

