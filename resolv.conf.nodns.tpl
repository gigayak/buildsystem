; Copied from <buildsystem>/resolv.conf.nodns.tpl
; This resolv.conf is populated into a container if it is created when no DNS
; servers are online.  This should only happen in a few cases, namely, when
; building the infrastructure packages required to bring a DNS server online.
; If this is found in a container that is not a DNS server, it's probably time
; to panic.
; TODO: Can launch_container.sh throw a warning (or error) if this occurs?
nameserver 8.8.8.8
