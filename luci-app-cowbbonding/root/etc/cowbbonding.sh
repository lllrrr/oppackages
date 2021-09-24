#!/bin/bash
if [ -s /tmp/log/COWB_BND_SUM ]; then

	chk_ipts() {
		sleep 1
		iptables -w -t nat -C PREROUTING -j cowbbonding 2>/dev/null || /etc/init.d/cowbbonding start reload
	}

	I_ipt() {
		iptables -w -t nat -D PREROUTING -j cowbbonding 2>/dev/null
		iptables -w -t nat -C PREROUTING -j cowbbonding 2>/dev/null || iptables -w -t nat -I PREROUTING -j cowbbonding 2>/dev/null
	}

	chk_index() {
		LPT=$(iptables -w -t nat -L PREROUTING)
		SWOBL=$(echo "$LPT" | grep '^SWOBL')
		domainfilter=$(echo "$LPT" | grep '^domainfilter')
		INDEX0=$(echo "$LPT" | tail +3 | sed -n -e '/^cowbbonding/=' | tail -1)
		if [ -n "$SWOBL" -a -n "$domainfilter" ]; then
			INDEX=3
		elif [ -z "$SWOBL" -a -n "$domainfilter" ]; then
			INDEX=2
		elif [ -n "$SWOBL" -a -z "$domainfilter" ]; then
			INDEX=2
		else
			INDEX=1
		fi
		[ -n "$INDEX0" ] && {
			[ "$INDEX0" -gt "$INDEX" ] && I_ipt
			return
		} || chk_ipts
	}

	while :; do
		sleep 10
	done
fi
