#!/bin/bash
. /usr/share/libubox/jshn.sh

OUTPUT=$(ubus call network.interface.wan6 status)

json_init
json_load "$OUTPUT"

if json_is_a "ipv6-prefix" array; then
	json_select "ipv6-prefix"
	have_ipv6_pd=0
	idx=1
	while json_is_a $idx object; do
		json_select $idx
		if json_is_a "address" string; then
			json_get_var ipv6_addr address
			json_get_var ipv6_mask mask
			have_ipv6_pd=1
			logger -p 6 -t "wan6mon" "IPv6 Prefix Delegation looks good. Current ipv6-pd: $ipv6_addr/$ipv6_mask"
			break
		fi
		idx=$(( idx + 1 ))
	done
	if [ $have_ipv6_pd -eq 0 ]; then
		logger -p 4 -t "wan6mon" "IPv6 Prefix Delegation seems gone."
		logger -p 6 -t "wan6mon" "Stoping odhcpd."
		/etc/init.d/odhcpd stop
		sleep 3
		logger -p 6 -t "wan6mon" "Stoping interface wan6."
		ifdown wan6
		sleep 3
		logger -p 6 -t "wan6mon" "Starting odhcpd."
		/etc/init.d/odhcpd start
		sleep 3
		logger -p 6 -t "wan6mon" "Starting interface wan6."
		ifup wan6
	fi
else
	logger -p 4 -t "wan6mon" "ipv6-prefix not an array or not found in ubus status."
fi