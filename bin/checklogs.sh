#! /bin/bash

#
# Checklogs - Check for very large log files
# 	by Sophie Forceno
# 
# Check for very large log files and alert the system administrator

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Check if machines are available before updating
source "$bin_path"/hosts-check.sh

for i in "${HOSTS[@]}"; do
	echo "checklogs: Checking log files on: $i"
	# Pass $i and $device to remote host
	# Then, execute log size checking on remote host
	# Remote host must have SHuttle set up otherwise pushes won't be sent

	ssh "$user"@"$i" LC_i="$i" LC_device="$device" LC_mailto="$mailto" LC_logsize_thresh="$logsize_thresh" LC_shuttle_path="$shuttle_path" bash << 'EOF' 
	# Find all log files that exceed $logsize_thresh and obtain the size and file name
	logsizes=$(find /var/log -maxdepth 1 -type f -size +$LC_logsize_thresh -exec ls -lh {} \+ | awk '{ print $5 "  " $9 }')
	
	# If there are large log files, send a push notification
	if [[ -n "$logsizes" ]]; then
	  # echo -e "$logsizes" | mail -s "checklogs: Large log files detected!" "$LC_mailto"
		echo -e "$logsizes" | "$LC_shuttle_path"/shuttle -p -n "$LC_device" "$LC_i: Large log files detected!" 
	fi
EOF
done

exit 0



