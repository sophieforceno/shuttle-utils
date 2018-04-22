#! /bin/bash

# hosts-check.sh - Helper script that checks host connectivity
# 	By Andy Forceno <aforceno@pm.me>
# 

# Sourced within each SHuttle-utils script
# You must populate $conf_path/hosts with your hosts!

# Check if machines are available
for i in "${HOSTS[@]}"; do
        ping -c 1 -W 1 "$i" > /dev/null
    rc=$?
    if [[ $rc != 0 ]]; then
	# Remove from array hosts that are down
	# Only match exact patterns
    HOSTS=($(echo "${HOSTS[@]}" | sed -e "s/\<$i\>//g"))
    fi
done

