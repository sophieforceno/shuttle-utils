#! /bin/bash

# spaced - Low Disk Space Notifier
# 	By Andy Forceno <aforceno@pm.me>
#

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Check if hosts are available before checking disc space
source "$bin_path"/hosts-check.sh

# Everything after the ssh command will be executed on each remote host
for i in "${HOSTS[@]}"; do
	echo "Spaced: Checking disk space on: $i"
# Pass $i to remote host
	ssh "$user"@"$i" LC_i="$i" LC_device="$device" LC_percent="$percent" LC_mailto="$mailto" LC_shuttle_path="$shuttle_path" bash << 'EOF' 
# List of all block devices
	df_output=$(df -Ph | grep -E "/dev/sd.*|ubi0")
	df_heading=$(df -lh | head -1)
# Devices
	dev_name=($(echo -e "$df_output" | awk '{ print $1 }'))
# Mountpoints
	mounts=($(echo -e "$df_output" | awk '{ print $6 }'))
# Percent free space
	free_space=($(echo -e "$df_output" | awk '{ print $5 }' | tr -d '%'))

# For each line in $free_space, if $j < some %, warn user
	for j in "${free_space[@]}"; do
		if [[ "$j" > "$LC_percent" ]]; then
			# Used to match each line with free space < $percent
			line_num=$(echo "$df_output" | grep -inw "$j" | cut -d: -f1)
			# df line of drive info, with line number removed
			j_df_line=$(echo "$df_output" | sed -n $line_num'p' | cut -d: -f2-)
			# Percentage of used spaced
			j_used_space=$(echo -e "$df_output" | sed -n $line_num'p' | awk '{ print $5 }' | tr -d '%')
			# Percentage of free space
			j_free_space=$((100-$j_used_space))
			# Mount point of device
			j_mount_point=$(echo -e "$df_output" | sed -n $line_num'p' | awk '{ print $6 }') 
			# Name of device (e.g. /dev/sda)
			j_dev_name=$(echo -e "$df_output" | sed -n $line_num'p' | awk '{ print $1 }' )
		
			echo "Spaced: $LC_i: $j_dev_name has $j_free_space% free space!"
		#	echo -e "$df_heading\n$j_df_line" | mail -s "space.d: Low disk space for $j_dev_name" "$LC_mailto"
			echo "$j_mount_point partition has $j_free_space% free space" | "$LC_shuttle_path"/shuttle -p -n "$LC_device" "$LC_i: Low disk space for $j_dev_name" 
		fi
	done
EOF
done
exit 0
