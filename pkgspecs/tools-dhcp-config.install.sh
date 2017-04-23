#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

# Build an initscript that ups the network interface.
# TODO: Support rest of init interface (stop, status?).
# TODO: Support all network interfaces.
cat > "$CLFS/tools/$YAK_TARGET_ARCH/etc/rc.d/init.d/eth0" <<EOF
#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
if [[ "\$1" != "start" ]]
then
  echo "This script is dumb and can only start."
  exit 0
fi

for binary in ip dhclient
do
  for bindir in \\
    /bin \\
    /usr/bin \\
    /sbin \\
    /usr/sbin \\
    /tools/${YAK_TARGET_ARCH}/bin \\
    /tools/${YAK_TARGET_ARCH}/sbin
  do
    if [[ ! -e "\$bindir/\$binary" ]]
    then
      continue
    fi
    export "\$binary"="\$bindir/\$binary"
  done
  if [[ -z "\${!binary}" ]]
  then
    echo "Failed to find binary \$binary." >&2
    exit 1
  fi
done

echo "Starting eth0"
\${ip} link set eth0 up
\${dhclient} -v eth0
EOF
chmod +x "$CLFS/tools/$YAK_TARGET_ARCH/etc/rc.d/init.d/eth0"
ln -sv ../init.d/eth0 \
  "$CLFS/tools/$YAK_TARGET_ARCH/etc/rc.d/rcsysinit.d/S70eth0"

# dhclient-script is required to get the connection working - it actually takes
# the results of the lease and assigns them to the interface.
#
# The stock ISC dhclient-script still uses the ancient net-tools package for
# things, so this is a modified version set up to avoid that.
cat > "$CLFS/tools/$YAK_TARGET_ARCH/sbin/dhclient-script" <<EOF
#!/bin/bash
# dhclient-script for Linux. Dan Halbert, March, 1997.
# Updated for Linux 2.[12] by Brian J. Murrell, January 1999.
# iproute2 update for IPv4 addresses courtesy of 
# Linux From Scratch (www.linuxfromscratch.org) May 2008.
# http://www.linuxfromscratch.org/patches/downloads/dhcp/dhcp-4.0.0-iproute2-1.patch

# Notes:

# This script is based on the netbsd script supplied with dhcp-970306.

# These patches attempt to fix PATH issues:
#   /sbin/dhclient-script: line 141: hostname: command not found
#   /sbin/dhclient-script: line 165: ifconfig: command not found
#   /sbin/dhclient-script: line 172: route: command not found
#   /sbin/dhclient-script: line 31: chmod: command not found
#   /sbin/dhclient-script: line 44: mv: command not found
bindirs=(\\
  /sbin /bin /usr/sbin /usr/bin \\
  "/tools/${YAK_TARGET_ARCH}/sbin" \\
  "/tools/${YAK_TARGET_ARCH}/bin" \\
)
for binary in ip hostname chmod mv sleep
do
  for bindir in "\${bindirs[@]}"
  do
    if [[ ! -e "\$bindir/\$binary" ]]
    then
      continue
    fi
    echo "dhclient-script: using \$binary at \$bindir/\$binary" >&2
    export "\$binary"="\$bindir/\$binary"
  done
  if [[ -z "\${!binary}" ]]
  then
    echo "dhclient-script: failed to find \$binary command" >&2
    exit 1
  fi
done
EOF
cat >> "$CLFS/tools/$YAK_TARGET_ARCH/sbin/dhclient-script" <<'EOF'

make_resolv_conf() {
  if [ x"$new_domain_name_servers" != x ]; then
    cat /dev/null > /etc/resolv.conf.dhclient
    ${chmod} 644 /etc/resolv.conf.dhclient
    if [ x"$new_domain_search" != x ]; then
      echo search $new_domain_search >> /etc/resolv.conf.dhclient
    elif [ x"$new_domain_name" != x ]; then
      # Note that the DHCP 'Domain Name Option' is really just a domain
      # name, and that this practice of using the domain name option as
      # a search path is both nonstandard and deprecated.
      echo search $new_domain_name >> /etc/resolv.conf.dhclient
    fi
    for nameserver in $new_domain_name_servers; do
      echo nameserver $nameserver >>/etc/resolv.conf.dhclient
    done

    ${mv} /etc/resolv.conf.dhclient /etc/resolv.conf
  elif [ "x${new_dhcp6_name_servers}" != x ] ; then
    cat /dev/null > /etc/resolv.conf.dhclient6
    ${chmod} 644 /etc/resolv.conf.dhclient6

    if [ "x${new_dhcp6_domain_search}" != x ] ; then
      echo search ${new_dhcp6_domain_search} >> /etc/resolv.conf.dhclient6
    fi
    shopt -s nocasematch 
    for nameserver in ${new_dhcp6_name_servers} ; do
      # If the nameserver has a link-local address
      # add a <zone_id> (interface name) to it.
      if  [[ "$nameserver" =~ ^fe80:: ]]
      then
	zone_id="%$interface"
      else
	zone_id=
      fi
      echo nameserver ${nameserver}$zone_id >> /etc/resolv.conf.dhclient6
    done
    shopt -u nocasematch 

    ${mv} /etc/resolv.conf.dhclient6 /etc/resolv.conf
  fi
}

dec_to_bin() {
  local n=$1
  local ret=""
  while [ $n != 0 ]; do
    ret=$[$n%2]$ret
    n=$[$n>>1]
  done
  echo $ret
}

mask_to_bin() {
  echo `dec_to_bin $1``dec_to_bin $2``dec_to_bin $3``dec_to_bin $4`
}

cidr_convert() {
  netmask=$1
  local mask=`mask_to_bin ${netmask//./ }`
  mask=${mask%%0*}
  echo ${#mask}
}

# Must be used on exit.   Invokes the local dhcp client exit hooks, if any.
exit_with_hooks() {
  exit_status=$1
  if [ -f /etc/dhclient-exit-hooks ]; then
    . /etc/dhclient-exit-hooks
  fi
# probably should do something with exit status of the local script
  exit $exit_status
}

# Invoke the local dhcp client enter hooks, if they exist.
if [ -f /etc/dhclient-enter-hooks ]; then
  exit_status=0
  . /etc/dhclient-enter-hooks
  # allow the local script to abort processing of this state
  # local script must set exit_status variable to nonzero.
  if [ $exit_status -ne 0 ]; then
    exit $exit_status
  fi
fi

###
### DHCPv4 Handlers
###

if [ x$new_broadcast_address != x ]; then
  new_broadcast_arg="broadcast $new_broadcast_address"
fi
if [ x$old_broadcast_address != x ]; then
  old_broadcast_arg="broadcast $old_broadcast_address"
fi
if [ x$new_subnet_mask != x ]; then
  new_subnet_arg=`cidr_convert $new_subnet_mask`
fi
if [ x$old_subnet_mask != x ]; then
  old_subnet_arg=`cidr_convert $old_subnet_mask`
fi
if [ x$new_interface_mtu != x ]; then
  mtu_arg="mtu $new_interface_mtu"
fi
if [ x$IF_METRIC != x ]; then
  metric_arg="metric $IF_METRIC"
fi

if [ x$reason = xMEDIUM ]; then
  # Linux doesn't do mediums (ok, ok, media).
  exit_with_hooks 0
fi

if [ x$reason = xPREINIT ]; then
  if [ x$alias_ip_address != x ]; then
    # Bring down alias interface. Its routes will disappear too.
    ${ip} link set $interface down
    ${ip} addr del $alias_ip_address  dev $interface
  fi
  ${ip} link set $interface up

  # We need to give the kernel some time to get the interface up.
  sleep 1

  exit_with_hooks 0
fi

if [ x$reason = xARPCHECK ] || [ x$reason = xARPSEND ]; then
  exit_with_hooks 0
fi
  
if [ x$reason = xBOUND ] || [ x$reason = xRENEW ] || \
   [ x$reason = xREBIND ] || [ x$reason = xREBOOT ]; then
  current_hostname=`${hostname}`
  if [ x$current_hostname = x ] || \
     [ x$current_hostname = "x(none)" ] || \
     [ x$current_hostname = xlocalhost ] || \
     [ x$current_hostname = x$old_host_name ]; then
    if [ x$new_host_name != x$old_host_name ]; then
      ${hostname} "$new_host_name"
    fi
  fi
    
  if [ x$old_ip_address != x ] && [ x$old_ip_address != x$new_ip_address ]; then
    # IP address changed. Bring down the interface, delete all routes, and
    # clear the ARP cache.
    ${ip} link set $interface down
    ${ip} addr flush dev $interface
  fi
  if [ x$old_ip_address = x ] || [ x$old_ip_address != x$new_ip_address ] || \
     [ x$reason = xBOUND ] || [ x$reason = xREBOOT ]; then

    ${ip} link set $interface up
    ${ip} addr add $new_ip_address/$new_subnet_arg $new_broadcast_arg \
        label $interface dev $interface

    # Add a network route to the computed network address.
    for router in $new_routers; do
      # These 3 lines were not in the patch :(
      #if [ "x$new_subnet_mask" = "x255.255.255.255" ] ; then
      #  route add -host $router dev $interface
      #fi
      # Patch did not specify interface - seems dangerous? Should I try this?
      #${ip} route add default via $router dev $interface # TODO: check?
      ${ip} route add default via $router
    done
  else
    # TODO: I did this patch by hand, since it was not in the LFS patch.
    # we haven't changed the address, have we changed other options           
    # that we wish to update?
    if [ x$new_routers != x ] && [ x$new_routers != x$old_routers ] ; then
      # if we've changed routers delete the old and add the new.
      for router in $old_routers; do
        #route del default gw $router
        ${ip} route del default via $router
      done
      for router in $new_routers; do
        #if [ "x$new_subnet_mask" = "x255.255.255.255" ] ; then
	#  #route add -host $router dev $interface
	#fi
	#route add default gw $router $metric_arg dev $interface
        ${ip} route add default via $router dev $interface
        # TODO: make metric_arg work, and worry about blank $interface
      done
    fi
  fi
  make_resolv_conf
  exit_with_hooks 0
fi

if [ x$reason = xEXPIRE ] || [ x$reason = xFAIL ] || [ x$reason = xRELEASE ] \
   || [ x$reason = xSTOP ]; then
  if [ x$old_ip_address != x ]; then
    # Shut down interface, delete routes, and clear arp cache.
    ${ip} link set $interface down
    ${ip} addr flush dev $interface
  fi
  exit_with_hooks 0
fi

if [ x$reason = xTIMEOUT ]; then
  ${ip} link set $interface up
  ${ip} addr set $new_ip_address/$new_subnet_arg $new_broadcast_arg \
      label $interface dev $interface
  set $new_routers
  for router in $new_routers; do
    ${ip} route add default via $router
  done
  
  make_resolv_conf
  exit_with_hooks 0
  # TODO: Do these lines do anything?  exit_with_hooks seems to imply these are
  # unreachable.
  ${ip} link set $interface down
  ${ip} addr flush dev $interface
  exit_with_hooks 1
fi

###
### DHCPv6 Handlers
###

if [ x$reason = xPREINIT6 ] ; then
  # Ensure interface is up.
  ${ip} link set ${interface} up

  # Remove any stale addresses from aborted clients.
  ${ip} -f inet6 addr flush dev ${interface} scope global permanent

  exit_with_hooks 0
fi

if [ x${old_ip6_prefix} != x ] || [ x${new_ip6_prefix} != x ] ; then
    echo Prefix ${reason} old=${old_ip6_prefix} new=${new_ip6_prefix}

    exit_with_hooks 0
fi

if [ x$reason = xBOUND6 ] ; then
  if [ x${new_ip6_address} = x ] || [ x${new_ip6_prefixlen} = x ] ; then
    exit_with_hooks 2;
  fi

  ${ip} -f inet6 addr add ${new_ip6_address}/${new_ip6_prefixlen} \
	dev ${interface} scope global

  # Check for nameserver options.
  make_resolv_conf

  exit_with_hooks 0
fi

if [ x$reason = xRENEW6 ] || [ x$reason = xREBIND6 ] ; then
  if [ x${new_ip6_address} != x ] && [ x${new_ip6_prefixlen} != x ] ; then
    ${ip} -f inet6 addr add ${new_ip6_address}/${new_ip6_prefixlen} \
	dev ${interface} scope global
  fi

  # Make sure nothing has moved around on us.

  # Nameservers/domains/etc.
  if [ "x${new_dhcp6_name_servers}" != "x${old_dhcp6_name_servers}" ] ||
     [ "x${new_dhcp6_domain_search}" != "x${old_dhcp6_domain_search}" ] ; then
    make_resolv_conf
  fi

  exit_with_hooks 0
fi

if [ x$reason = xDEPREF6 ] ; then
  if [ x${new_ip6_prefixlen} = x ] ; then
    exit_with_hooks 2;
  fi

  ${ip} -f inet6 addr change ${new_ip6_address}/${new_ip6_prefixlen} \
       dev ${interface} scope global preferred_lft 0

  exit_with_hooks 0
fi

if [ x$reason = xEXPIRE6 -o x$reason = xRELEASE6 -o x$reason = xSTOP6 ] ; then
  if [ x${old_ip6_address} = x ] || [ x${old_ip6_prefixlen} = x ] ; then
    exit_with_hooks 2;
  fi

  ${ip} -f inet6 addr del ${old_ip6_address}/${old_ip6_prefixlen} \
	dev ${interface}

  exit_with_hooks 0
fi

exit_with_hooks 0
EOF
chmod +x "$CLFS/tools/${YAK_TARGET_ARCH}/sbin/dhclient-script"
ln -sv "/tools/${YAK_TARGET_ARCH}/sbin/dhclient-script" \
  "$CLFS/sbin/dhclient-script"
