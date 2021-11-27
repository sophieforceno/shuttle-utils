# !/bin/bash

# apcstats - APC UPS stats push notifier
#	by Sophie Forceno
#

# Your APC UPS must be accessible via computer this is executed on, such through a USB or serial cable

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

timeleft=$(apcaccess -p TIMELEFT)
load=$(apcaccess -p LOADPCT)
charge=$(apcaccess -p BCHARGE)

body="Battery Charge: $charge\nTime remaining: $timeleft\nLoad Percentage: $load"

printf "%s" "$body" | shuttle -p -n "$device" "$HOSTNAME: APC UPS Stats ($(date +%-m-%d-%y))"
