#! /bin/bash

# reboot_notif - Notify if reboot is needed 
# 	by Andy Forceno <aforceno@pm.me>
#
# Sends a push notification to specified device if a reboot is needed 

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Check if hosts are available
source "$bin_path"/hosts-check.sh


for i in "${HOSTS[@]}"; do
# Pass local variables to remote hosts
	ssh "$user"@"$i" LC_i="$i" LC_device="$device" LC_shuttle_path="$shuttle_path" bash << 'EOF'

	# Last reboot date/time
	last_reboot=$(uptime -s)
	
	if [[ -f /var/run/reboot-required ]]; then
	# Echo for logging purposes
		echo "reboot_notif: "$HOSTNAME" requires a reboot. Last reboot was on "$last_reboot""
	echo "Last reboot was $last_reboot" | "$LC_shuttle_path"/shuttle -p -n "$LC_device" "$(echo $HOSTNAME): reboot required"
	fi
EOF
done
