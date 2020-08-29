#! /bin/bash

# ipnotif: IP Address Change Push Notifier
# by Andy Forceno <aforceno@pm.me>
#

# Uses the IPify API to obtain external IP
# And compares it to the previously obtained address
# Depends on: curl

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

if [ -e "$conf_path"/.iphistory ]; then
	last_ip=$(tac "$conf_path"/.iphistory | grep -m 1 '.' | awk '{print $4}')
else
	touch "$conf_path"/.iphistory
fi

# API call to obtain IP address
# See: https://www.ipify.org/
new_ip=$(curl -s 'https://api6.ipify.org?format=text')

if [[ "$last_ip" != "$new_ip" && -n "$new_ip" && -n "$last_ip" && -n "$new_ip" ]]; then
	"$shuttle_path"/shuttle -p -n "$device" "$HOSTNAME: External IP address change" "Current IP: $new_ip"
# Write date & address to file for IP address history
	echo "$(date "+%D %H:%M") - $new_ip" >> $conf_path/.iphistory
fi
