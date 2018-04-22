#! /bin/bash

# smartmon_test - Perform the S.M.A.R.T. Extended Test on many remote hosts
# 	by Andy Forceno <aforceno@pm.me>
#
# Runs the long S.M.A.R.T. test for disks on remote hosts

# INFO: To parse and push the test results, run smartmon_results

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Check if hosts are available before running remote SMART tests
source "$bin_path"/hosts-check.sh

# Create shuttle-utils config dir and files
if [[ ! -d "$conf_path" ]]; then
	mkdir "$conf_path"
	touch $conf_path/.smart_hosts
fi
echo "${HOSTS[@]}" > "$conf_path"/.smart_hosts

# Iterate through hosts list
for i in "${HOSTS[@]}"; do
	echo "smartmon_test: Connecting to: $i"

	# Remove /dev/sdc if host = Aurorabox
	if [[ "$i" = "Aurorabox" ]]; then
		unset DISKS[1]
		# Remove null element left behind (precautionary)
		for elem in "${!DISKS[@]}"; do 
 			[ -n "${DISKS[$elem]}" ] || unset "HOSTS[$elem]" 
		done
	fi

# Required to pass DISKS array to remote hosts
# Thanks to Stéphane Chazelas
# See: http://unix.stackexchange.com/a/342575/123270
DISKS_def=$(typeset -p DISKS)

# Pass locally-defined variables to remote host
LC_DISKS="$DISKS_def" ssh "$user"@"$i" LC_i="$i" LC_disk_type="$disk_type" bash << 'EOF' 
eval "${LC_DISKS[@]}"

# Proceed with SMART test only if smartctl exists on remote host
	if [[ -n "$(which smartctl)" ]]; then
		echo -e "smartmon_test: Begin SMART extended test for host: $LC_i"
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
	   		long_test=$(sudo smartctl -t long -d "$LC_disk_type" "$j")
	   		test_time=$(sudo smartctl -c -d "$LC_disk_type" "$j" | grep -o -P '.{0,6}minutes' | sed -e 's/) minutes//g' -e 's/^ *//' | head -2 | tail -1)
	    	echo "smartmon_test: Extended test of $j in progress for the next $test_time minutes..."
	 	   done
    	fi
EOF
done
