# !/bin/bash

# apcstats - APC UPS stats push notifier
#	by Andy Forceno <andy@aurorabox.tech>
#

# Your APC UPS must be accessible via computer this is executed on, such through a USB or serial cable

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

timeleft=$(apcaccess | awk -F: '/TIMELEFT/ { print $2 }')
load=$(apcaccess | awk -F: '/LOADPCT/ { print $2 }')
charge=$(apcaccess | awk -F: '/BCHARGE/ { print $2 }')

body="Battery Charge:$charge\nTime remaining:$timeleft\nLoad Percentage:$load"

printf "%s" "$body" | shuttle -p -n "$device" "$HOSTNAME: APC UPS Stats for $(date +%-m-%d-%y)"
