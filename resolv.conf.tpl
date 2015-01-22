; copied in from <buildsystem>/resolv.conf.tpl

; These options force us to choose a DNS replica at random, and to fail over
; after a single attempt fails to return within one second.
options timeout:1 attempts:1 rotate

; This IP should correspond to the first DNS replica in create_all_containers.sh
nameserver 192.168.122.6

; This IP should correspond to the second DNS replica.
; TODO: This should be on a second machine in the long run.
nameserver 192.168.122.7

; TODO: There are 3 nameservers allowed in the resolv.conf file.  Geographic
;       failover might be nice.
