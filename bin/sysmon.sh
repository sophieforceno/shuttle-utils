#! /bin/bash

# Sysmon - Check CPU/GPU temps and system load 
# 	By Andy Forceno <andy@aurorabox.tech>
#
# This script depends on sensors and nvclock

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Check if machines are available
source "$bin_path"/hosts_check.sh

for i in "${HOSTS[@]}"; do
# Pass local vars to remote hosts
	ssh "$user"@"$i" LC_i="$i" LC_NVCLOCK_HOSTS="${NVCLOCK_HOSTS[@]}" LC_percent="$percent" LC_temp_thresh="$temp_thresh" LC_gpu_temp_thresh="$gpu_temp_thresh" LC_load_thresh="$load_thresh" LC_shuttle_path="$shuttle_path" bash -x << 'EOF'
		temp=$(sensors -u | awk -F: '/temp1_input/ { print $2 }' | head -n1 | sed -e 's/\..*$//g' -e 's/^ //g')

	# Evaluate CPU temp, send push if > threshold
	if (( "$temp" >= "$LC_temp_thresh" )); then
		"$shuttle_path"/shuttle -p -n all "$LC_i: Temperatures above $(echo "$LC_temp_thresh" | sed 's/\..*$/°C/g') detected!" "Current temperature: $LC_temp at $(date +%H:%M) on $(date +%Y-%m-%d)"
	fi
		# If host exists in ${NVCLOCK_HOSTS}, check the Nvidia GPU temp
		if [[ "$HOSTNAME" =~ "${LC_NVCLOCK_HOSTS[@]}" ]]; then
			gpu_temp=$(sudo nvclock -T | tail -n1 | awk '{ print $4 }' | sed 's/C//g')
			# If $gpu_temp >= $gpu_temp_thresh, push a warning!
			if (( "$gpu_temp" >= "$LC_gpu_temp_thresh" )); then
				$shuttle_path/shuttle -p -n all "$LC_i: GPU temperatures above $(echo "$LC_gpu_temp_thresh" | sed 's/\..*$/°C/g') detected!" "Current temperature: $LC_gpu_temp at $(date +%H:%M) on $(date +%Y-%m-%d)"
			fi
		fi
	# Check 5 minute system load, send warning if load > threshold
	# Raw load value (decimal)
	load_raw=$(uptime | grep -ohe "load average[s:][: ].*" | awk '{ print $4 }' | tr -d ',')
	# load value as a whole number
	load_int=$(echo "$load_raw" | sed 's/\..*//g')	
	if (( "$load_int" > "$LC_load_thresh" )); then
		"$LC_shuttle_path"/shuttle -p -n all "$LC_i: System load above $(echo "$LC_load_thresh") detected!" "Current load: $load_raw at $(date +%H:%M) on $(date +%Y-%m-%d)"
	fi

EOF
done

exit 0
