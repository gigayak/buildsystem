#!/bin/bash
set -Eeo pipefail
cat > /etc/container.mounts <<'EOF'
samba /opt/samba
samba_private /opt/samba_private
EOF

# TODO: I really need to move this to LDAP, or some other login system.
# Seriously: my user account shouldn't be hardcoded here.
cat > /usr/bin/container.init <<'EOF_INIT'
#!/bin/bash
set -Eeo pipefail

cat > /etc/samba.conf <<'EOF'
[global]
encrypt passwords = yes
security = user
encrypt passwords = yes
smb passwd file = /opt/samba_private/private/smb.passwd
log level = 1

[Main]
path = /opt/samba/main
valid users = jgilik
writable = yes
EOF

chmod 0755 / # got to fix the root permissions eventually
chmod 1777 /tmp # make sure any user can use /tmp, gotta fix this too

# share directory
mkdir -pv /opt/samba/main
chmod 0777 /opt/samba/main

if ! grep jgilik /etc/passwd >/dev/null 2>&1
then
  echo 'jgilik:x:10000:10000::/home/jgilik:/bin/false' >> /etc/passwd
fi
if ! grep jgilik /etc/group >/dev/null 2>&1
then
  echo 'jgilik:x:10000:' >> /etc/group
fi

mkdir -pv /home/jgilik
chown jgilik: /home/jgilik

# You may want to run smbpasswd -a jgilik -c /etc/samba.conf

smbd --foreground --log-stdout --configfile=/etc/samba.conf
EOF_INIT
chmod +x /usr/bin/container.init
