#! /bin/bash

# smartmon_result - S.M.A.R.T. Extended Test Results Push Notifier
# 	by Sophie Forceno
#

# It is recommended to run this weekly via cron, after smartmon_test
# How long depends on your systems and drives. I find a 4 hour gap effective.

# INFO: You will need passwordless-sudo on the remote devices to automate this script

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Only request test results from hosts that ran the extended test
HOSTS=($(cat "$conf_path"/.smart_hosts))

# Check if hosts are available before running remote SMART tests
source "$bin_path"/hosts-check.sh

# Required to pass DISKS array to remote hosts
# Thanks to Stéphane Chazelas
# See: http://unix.stackexchange.com/a/342575/123270
DISKS_def=$(typeset -p DISKS)
for i in "${HOSTS[@]}"; do
  LC_DISKS="$DISKS_def" ssh "$user"@"$i" LC_i="$i" LC_device="$device" LC_mailto="$mailto" LC_disk_type="$disk_type "LC_conf_path="$conf_path" LC_shuttle_path="$shuttle_path" bash << 'EOF'
    eval "$LC_DISKS"
    echo -e "smartmon_log: Processing SMART long test results for host: $LC_i"
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
      curr_date=$(date +%Y-%m-%d)
      long_results=$(sudo smartctl -l selftest -d "$LC_disk_type" "$j" | head -10)
    # echo -e "$(date +%R) on $(date +%m-%d-%y):\n $long_results" | mail -s "$LC_i: SMART extended test for $j" "$LC_mailto"
      printf "%s\n" "$long_results" | "$LC_shuttle_path"/shuttle -p -n "$LC_device" "$LC_i: SMART extended test results for $j"
    done
EOF
done
