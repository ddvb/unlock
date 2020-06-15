#!/bin/sh

file="/tmp/vpnup.lock"
if [ ! -f "$file" ]; then
	username=$(grep username /etc/config/vpn | cut -f 2 -d "'")
	password=$(grep password /etc/config/vpn | cut -f 2 -d "'")
	mac=$(ip link show br-lan | awk -e '/^\s*link\//{print $2}')
	pass=$(echo -n $password | md5sum | cut -f 1 -d " ")
	mod=$(cat /proc/cpuinfo | grep machine | cut -d: -f2 | sed 's/\ //g')
	wget --no-check-certificate "https://www.7d24hrs.com/v201804/config?username="$username"&password="$pass"&mac="$mac"&mod="$mod -O /etc/stunnel/stunnel.temp 
	if [ $(grep 0.0.0.0 /etc/stunnel/stunnel.temp) ]; then
		exit 0
	else
		cp -r /etc/stunnel/stunnel.temp /etc/stunnel/stunnel.conf
		killall -9 stunnel
		/etc/init.d/stunnel start
		cp /etc/dnsmasq.conf.v /etc/dnsmasq.conf
		/etc/init.d/redsocks stop
		/etc/init.d/redsocks start
		/etc/init.d/dnscrypt-proxy stop
		/etc/init.d/dnscrypt-proxy start
		/etc/init.d/dnsmasq stop
		/etc/init.d/dnsmasq start
		/etc/init.d/chinadns stop
		/etc/init.d/chinadns start
#		/etc/config/vipin/ledon.sh
		rm -rf /tmp/vpndown.lock
		touch "$file"
	fi
fi
rm -rf /tmp/vpn.lock
