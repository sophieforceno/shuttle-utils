#! /bin/bash

# hostname-isup - Ping hosts to check if they're up  
# 	by Andy Forceno <andy@aurorabox.tech>
#

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

for i in "${HOST_ADDR[@]}"; do
	ping -w 10 -c 3 "$i" > /dev/null
	rc=$?
	# If exit code != 0, ping failed so host is (probably) down!
	if [[ $rc -ne 0 ]]; then                  
		"$shuttle_path"/shuttle -p -n "$device" "$i is down or not responding to pings (rc = $rc)" > /dev/null
	fi
done
