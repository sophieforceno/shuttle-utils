#! /bin/bash

# procmon.sh - Monitors an array of processes and sends pushes informing of stopped processes
#
# 	By Andy Forceno <andy@aurorabox.tech>
#

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

	for j in "${SERVER_PROC[@]}"; do
		# Enclose first letter in [ ] so ps | grep command isn't listed in the grepped results
		j_bracket=$(echo "$j" | sed 's/./[\0]/') 
		proc_status=$(ps aux | grep -w "$j_bracket")

		if [[ -z "$proc_status" ]]; then
			# Add stopped processes to array
			STOPPED+="$j, "
		fi
done 

# If there are any stopped processes, send a push notification
if [[ "${#STOPPED[@]}" != 0 ]]; then
	echo "${STOPPED[@]}" | sed 's/,.$//' | shuttle -p -n chrome "Stopped processes:"
fi
