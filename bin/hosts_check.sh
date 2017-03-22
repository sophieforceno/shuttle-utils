#! /bin/bash

# hosts_check.sh - Helper script that checks host connectivity
# 	By Andy Forceno <andy@aurorabox.tech>
# 

# Sourced within each SHuttle-utils script
# You must populate $conf_path/hosts with your hosts!

# Check if machines are available before syncing
for i in "${HOSTS[@]}"; do
        ping -c 1 -i 0.5 "$i" > /dev/null
    rc=$?
    if [[ $rc != 0 ]]; then
	# Remove from array hosts that are down
	# Only match exact patterns
    HOSTS=($(echo "${HOSTS[@]}" | sed -e "s/\<$i\>//g"))
    fi
done

