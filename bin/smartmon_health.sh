#! /bin/bash

#
# smartmon_health.sh - S.M.A.R.T. Drive Health Push Notifier
# 	by Andy Forceno <andy@aurorabox.tech>
#
# Checks SMART drive health info for disks on remote hosts 
# Pushes info when specific drive parameters change

# It is recommeneded to run this daily via cron (as root user)
# And run the long test weekly (see smartmon_test.sh and smartmon_results.sh)

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Check if hosts are available before running remote SMART tests
source "$bin_path"/hosts_check.sh

# Required to pass DISKS array to remote hosts
# Thanks to Stéphane Chazelas
# See: http://unix.stackexchange.com/a/342575/123270
DISKS_def=$(typeset -p DISKS)
# Iterate through hosts list
for i in "${HOSTS[@]}"; do
echo -e "smartmon_health: Reading SMART data for disks on: $i"
LC_DISKS="$DISKS_def" ssh "$user"@"$i" LC_i="$i" LC_percent="$percent" LC_device="$device" LC_mailto="$mailto" LC_disk_type="$disk_type" LC_conf_path="$conf_path" LC_shuttle_path="$shuttle_path" bash << 'EOF' 
	# Script executes only on hosts that have smartctl
	# If which returns a string that begins with '/', then smartctl executable exists
	if [[ "$(which smartctl)" = \/* ]]; then
		eval "$LC_DISKS"
		# Create shuttle-utils config dir 
		if [[ ! -d "$LC_conf_path" ]]; then
			mkdir "$LC_conf_path"
		fi

		# Disks currently mounted on host
		MOUNTS=($(df -l | grep "\/dev\/" | awk '{ print $1 }'))
		# Remove partition number from end of device name
		for d in "${MOUNTS[@]}"; do
			# Trim last char of string
			d=$(echo "$d" | cut -c 1-8)
			# Iteratively assign to new array
			MOUNTS_TR+=("$d")
		done
		# Strip out unique matches to get just the raw drive names (/dev/sd*) on host
		UNIQ_MNTS=($(echo "${MOUNTS_TR[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

		# Compare mounted local disks to disks-to-be-checked
		# Add to an array the disks that match a disk-to-be-checked 
		for g in "${DISKS[@]}"; do
			for h in "${UNIQ_MNTS[@]}"; do
				if [[ "$g" = "$h" ]]; then
					TO_SCAN+=("$g")
				fi
			done
		done

		for j in "${TO_SCAN[@]}"; do
			smart_info=$(sudo smartctl -a -d "$LC_disk_type" "$j")
			drive_health=$(echo "$smart_info" | head -n30 | grep "overall-health" | awk -F': ' '{ print $2 }')
			# Only notify if test fails so we don't swamp the poor sys admin
			if [[ -n "$drive_health" && "$drive_health" != +(PASSED|OK) ]]; then
				echo "$smart_info" | mail -s "$LC_i: SMART Diagnostics for $j" "$LC_mailto"
				echo -e "$drive_health" | "$LC_shuttle_path"/shuttle -p -n "$LC_device" "$LC_i: SMART Diagnostics for $j"
			fi
		# TODO: If $i = aurorabox and $j = /dev/sdb skip all this, we just want PASSED health status
			# Read in saved SMART attribute values
			if [[ -e $LC_conf_path/.smart-attribs ]]; then
			    prev_realloc=$(grep "$j" "$LC_conf_path"/.smart-attribs | cut -d' ' -f2 | awk -F, '{ print $1 }')
				prev_pending=$(grep "$j" "$LC_conf_path"/.smart-attribs | cut -d' ' -f2 | awk -F, '{ print $2 }')
				prev_offline=$(grep "$j" "$LC_conf_path"/.smart-attribs | cut -d' ' -f2 | awk -F, '{ print $3 }')
			fi

			# Bad sectors that were moved
			realloc=$(echo -e "$smart_info" | awk '/Reallocated_Sector_Ct/ { print $10 }')
			# Bad sectors not yet corrected
			pending=$(echo -e "$smart_info" | awk '/Current_Pending_Sector/ { print $10 }')
			# Bad sectors that can't be corrected
			offline=$(echo -e "$smart_info" | awk '/Offline_Uncorrectable/ { print $10 }')
			
			# Delta values
			# If any of these are > 1, send a push
			# INFO: if you get a lot of pushes about a single drive, that drive may be failing!
			# Especially if the raw offline uncorrectable count increases frequently
			realloc_delta=$((realloc-prev_realloc))
			pending_delta=$((pending-prev_pending))
			offline_delta=$((offline-prev_offline))

			echo "$j $realloc,$pending,$offline" >> "$LC_conf_path"/smart-attribs.tmp		
			# If any delta values are positive, send a push notification
			if [[ "$realloc_delta" > 0 || "$pending_delta" > 0 || "$offline_delta" > 0 ]]; then
				printf "%s\n" "Reallocated +$realloc_delta, Pending +$pending_delta, Offline +$offline_delta" | "$LC_shuttle_path"/shuttle -p -n all "$LC_i: $j: SMART values have changed!"
			fi
		done
		mv "$LC_conf_path"/smart-attribs.tmp "$LC_conf_path"/.smart-attribs
	fi
EOF
done



