#!/bin/bash
# wulishui 20200120-20200428-20200914-20200923 v4.1.3 20201004 v4.1.4 20201005 v5.0.0 20201007 v5.0.6 20201010 v6.0.0 20201117 v6.0.1 20210227 v6.0.2 20210309 v6.0.3 20210314 v6.0.4 20210320 v6.0.5
# Author: wulishui <wulishui@gmail.com>

add_ipts() {
	target=$(echo "$line" | awk -F ' ' '{print $3}')
	type=$(echo "$line" | awk -F ' ' '{print $2}')
	if [ "$type" = "MAC" ]; then
		[ -z "$(grep -w "$target" /etc/${logfile})" ] && {
			echo "$target" >> /etc/${logfile}
			iptables -w -A ${iptname} -m mac --mac-source ${target} -j DROP 2>/dev/null
			ip6tables -w -A ${iptname} -m mac --mac-source ${target} -j DROP 2>/dev/null
		}
	elif [ "$type" = "IP4" ]; then
		[ -z "$(grep -w "$target" /etc/${logfile})" ] && {
			echo "$target" >> /etc/${logfile}
			iptables -w -A ${iptname} -s ${target} -j DROP 2>/dev/null
		}
	elif [ "$type" = "IP6" ]; then
		[ -z "$(grep -w "$target" /etc/${logfile})" ] && {
			echo "$target" >> /etc/${logfile}
			ip6tables -w -A ${iptname} -s ${target} -j DROP 2>/dev/null
		}
	fi
}

add_badhostsbnew() {
	#-------------------------grep target---------------------
	echo "$badhostsbnew" | while read line; do
		MAC=$(echo "$line" | egrep -o "([A-Fa-f0-9]{2}[:-]){5}[A-Fa-f0-9]{2}" | head -1) && target=$(echo "MAC "$MAC"")
		[ -z "$MAC" ] && { IP4=$(echo "$line" | egrep -o "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])" | head -1) && target=$(echo "IP4 "$IP4""); }
		[ -z "$MAC" -a -z "$IP4" ] && { IP6=$(echo "$line" | egrep -o "(s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*)" | head -1) target=$(echo "IP6 "$IP6""); }
		havetarget=$(grep -w "$target" /etc/pwdHackDeny/${badhostsfile})
		if [ -n "$havetarget" ]; then
			sumtarget=$(echo ${havetarget} | awk -F ' ' '{print $1}')
			sed -i '/'"$target"'/d' /etc/pwdHackDeny/${badhostsfile}
			echo "$((sumtarget + 1)) ${target} " >> /etc/pwdHackDeny/${badhostsfile}
		else
			echo "1 ${target} " >> /etc/pwdHackDeny/${badhostsfile}
		fi
		unset MAC
		unset IP4
		unset IP6
		unset target
	done
	unset badhostsbnew

	#--------------------------chk sum-------------------------
	if [ -s /etc/pwdHackDeny/${badhostsfile} ]; then
		cat /etc/pwdHackDeny/${badhostsfile} | awk NF | while read line; do
			sumtarget=$(echo "$line" | awk -F ' ' '{print $1}')
			[ "$sumtarget" -ge "$sum" ] && add_ipts
			unset target
			unset sumtarget
			unset type
		done
	fi
}

chk_log() {
	#--------------------------chklogsize-----------------------
	logsize=$(du /etc/pwdHackDeny/badip.log.web 2>/dev/null | awk '{print $1}') && [ "$logsize" -gt 80 ] && {
		cat /etc/pwdHackDeny/badip.log.web >> /etc/pwdHackDeny/bak.log.web
		echo "--------"$(date +"%Y-%m-%d %H:%M:%S")" ：日志文件过大，旧的记录已转移到 /etc/pwdHackDeny/bak.log.web 。--------" > /etc/pwdHackDeny/badip.log.web 2>/dev/null
	}
	logsize=$(du /etc/pwdHackDeny/badip.log.ssh 2>/dev/null | awk '{print $1}') && [ "$logsize" -gt 80 ] && {
		cat /etc/pwdHackDeny/badip.log.ssh >> /etc/pwdHackDeny/bak.log.ssh
		echo "--------"$(date +"%Y-%m-%d %H:%M:%S")" ：日志文件过大，旧的记录已转移到 /etc/pwdHackDeny/bak.log.ssh 。--------" > /etc/pwdHackDeny/badip.log.ssh 2>/dev/null
	}

	#---------------------------addlogfile----------------------
	logread | egrep 'dropbear.*[Pp]assword|uhttpd.*login' > /tmp/pwdHackDeny/syslog
	[ -s /tmp/pwdHackDeny/syslog ] || return 0

	touch /tmp/pwdHackDeny/syslog /tmp/pwdHackDeny/syslog_
	newlog=$(diff /tmp/pwdHackDeny/syslog_ /tmp/pwdHackDeny/syslog | grep '^>' | sed 's/^> //g' | uniq -i | sed '/^\s*$/d')
	cp -f /tmp/pwdHackDeny/syslog /tmp/pwdHackDeny/syslog_
	[ -n "$newlog" ] || return 0

	awk '/0x2/{print $1" "$4}' /proc/net/arp | tr '[a-z]' '[A-Z]' > /tmp/pwdHackDeny/MAC-IP.leases
	while read line; do
		BIP=$(echo "$line" | egrep -o "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])" | head -1) || BIP=$(echo "$line" | egrep -o "(s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:)))(%.+)?\\s*)" | head -1)
		[ -n "$BIP" ] && BIP=$(grep -w "$BIP" /tmp/pwdHackDeny/MAC-IP.leases | awk -F ' ' '{print $2}') && { [ "$(echo "$BIP" | wc -l)" -gt 1 ] && BIP=$(echo "$BIP" | head -1) && BARP=" ，此客户端在进行ARP欺骗！"; }
		sshwrong=$(echo "$line" | grep -o "Bad password attempt")
		webwrong=$(echo "$line" | grep -o "failed login on")
		if [ -n "$sshwrong" -o -n "$webwrong" ]; then
			echo ""$line" (Login Host : "$BIP" "$BARP")  <---------异常登录！！！" >> /tmp/pwdHackDeny/syslog.tmp
		else
			echo ""$line" (Login Host : "$BIP" "$BARP") " >> /tmp/pwdHackDeny/syslog.tmp
		fi
		unset BIP
		unset BARP
	done <<< "$newlog"
	unset newlog

	[ -s /tmp/pwdHackDeny/syslog.tmp ] || return 0
	egrep 'dropbear.*[Pp]assword' /tmp/pwdHackDeny/syslog.tmp >> /etc/pwdHackDeny/badip.log.ssh
	egrep 'uhttpd.*login' /tmp/pwdHackDeny/syslog.tmp >> /etc/pwdHackDeny/badip.log.web
	sum=$(uci get pwdHackDeny.pwdHackDeny.sum 2>/dev/null) || sum=5

	#----------------------------addbadsshlog------------------
	badhostsbnew=$(cat /tmp/pwdHackDeny/syslog.tmp 2>/dev/null | grep "Bad password attempt")
	if [ -n "$badhostsbnew" ]; then
		badhostsfile="badhosts.ssh"
		logfile="SSHbadip.log"
		iptname="pwdHackDenySSH"
		add_badhostsbnew
	fi

	#-----------------------------addbadweblog------------------
	badhostsbnew=$(cat /tmp/pwdHackDeny/syslog.tmp 2>/dev/null | grep "failed login on")
	if [ -n "$badhostsbnew" ]; then
		badhostsfile="badhosts.web"
		logfile="WEBbadip.log"
		iptname="pwdHackDenyWEB"
		add_badhostsbnew
	fi

	rm -f /tmp/pwdHackDeny/syslog.tmp 2>/dev/null
}

chk_ipts_2() {
	sleep 3
	[ $(iptables -w -L INPUT | grep -c 'pwdHackDeny') -ge 2 ] && [ $(ip6tables -w -L INPUT | grep -c 'pwdHackDeny') -ge 2 ] || /etc/init.d/pwdHackDeny restart
}

chk_ipts() {
	[ $(iptables -w -L INPUT | grep -c 'pwdHackDeny') -ge 2 ] && [ $(ip6tables -w -L INPUT | grep -c 'pwdHackDeny') -ge 2 ] || chk_ipts_2
}

enabled=$(uci get pwdHackDeny.pwdHackDeny.enabled 2>/dev/null)
if [ "$enabled" == 1 ]; then
	time=$(uci get pwdHackDeny.pwdHackDeny.time 2>/dev/null) || time=5
	while :; do
		chk_ipts
		chk_log
		sleep "$time"
	done
fi
