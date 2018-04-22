#! /bin/bash

# update_all - Run package updates (apt-get) on multiple hosts via dsh 
# 	By Andy Forceno <aforceno@pm.me>
#
# INFO: This script depends on dsh (Distributed Shell)

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

# Check if machines are available before updating
source "$bin_path"/hosts-check.sh
# Output online hosts to DSH hosts group file
printf '%s\n' "${HOSTS[@]}" > /etc/dsh/group/up

# Connect to each remote host specified in the /etc/dsh/group/up file and run apt-get update, upgrade, and autoremove
dsh -M -g up -c sudo apt-get -qq update > /dev/null 2>&1
# DEBIAN_FRONTEND: Set non-interactive frontend to avoid display issues with config file choice frontend
# --force-confold: Choose to preserve current config files on system, rather than package maintainer defaults
# --assume-yes: Assume yes answer to y/n prompts when updating and removing packages
# --with-new-pkgs: install new packages that updates depend on (this avoids packages being held back)
dsh -vM -g up -c DEBIAN_FRONTEND="noninteractive" > /dev/null 2>&1
dsh -vM -g up -c sudo apt-get -qq -o Dpkg::Options::="--force-confold" --assume-yes --with-new-pkgs upgrade > /dev/null 2>&1
dsh -vM -g up -c sudo apt-get -qq --assume-yes autoremove && wait $! > /dev/null 2>&1

for i in "${HOSTS[@]}"; do
	ssh "$user"@"$i" LC_i="$i" LC_device="$device" LC_logfile="$dpkg_log" LC_conf_path="$conf_path" LC_shuttle_path="$shuttle_path" bash << 'EOF'
	curr_date=$(date +%Y-%m-%d)
	upgraded=$(awk '/upgrade/ && /'$curr_date'/ { print $1 "   " $4 }' "$LC_logfile" | sort | uniq)
	installed=$(awk '/installed/ && /'$curr_date'/ { print $1 "   " $5 }' "$LC_logfile" | sort | uniq)
	removed=$(awk '/remove/ && /'$curr_date'/ { print $1 "   " $4 }' "$LC_logfile" | sort | uniq)
	
# INFO: Uncomment this if you want updates sent as a text file rather than a note. Use this if you are having trouble pushing the updates list via pipe.
	#if [ ! -d "$LC_conf_path" ]; then
	#	mkdir "$LC_conf_path"
	#fi
	#if [ ! -f "$LC_conf_path"/dpk-$curr_date ]; then
	#	touch "$LC_conf_path"/dpkg-$curr_date
	#fi
	# If there are updates of any kind, send a push to notifty of updates
	if [[ -n "$installed" || -n "$upgraded" || -n "$removed" ]]; then
		echo -e "Installed:\n$installed\n\nUpgraded:\n$upgraded\n\nRemoved:\n$removed" | column -t | shuttle -p -n chrome "$LC_i: Package updates for $curr_date"
		
	# INFO: Uncomment this to send the update log as a text file. Use this if you are having trouble pushing the updates list via pipe
		# Export the recently installed packages to a file, and push that. File must be in cwd, otherwise Pushbullet doesn't push it (a limitation of SHuttle)
		# echo -e "Package updates and removals on $LC_i\n\nInstalled:\n$installed\n\nUpgraded:\n$upgraded\n\nRemoved:\n$removed" > "$LC_conf_path"/dpkg-$curr_date
		# "$LC_shuttle_path"/shuttle -p -f "$LC_device" "$LC_i: Package updates for $curr_date" "" "$LC_conf_path/dpkg-$curr_date" 
		# rm -f "$LC_conf_path"/dpkg-$curr_date

		# INFO: Send the updates via mail, disabled by default
		# echo -e "Package updates and removals:\n\nInstalled:\n$installed\n\nUpgraded:\n$upgraded\n\nRemoved:\n$removed" | column | mail -s "$LC_i: Updated packages for $curr_date" "$mailto"
	fi
EOF
done

exit 0