# !/bin/bash

# apcstats.sh - APC UPS stats push notifier
#	by Andy Forceno <andy@aurorabox.tech>
#

# Time remaining on battery
timeleft=$(apcaccess | awk -F: '/TIMELEFT/ { print $2 }')
# Current load
load=$(apcaccess | awk -F: '/LOADPCT/ { print $2 }')
# Current charge in percent
charge=$(apcaccess | awk -F: '/BCHARGE/ { print $2 }')

# Push body to be piped to SHuttle
body="Battery Charge:$charge\nTime remaining:$timeleft\nLoad Percentage:$load"

printf "%s" "$body" | shuttle -p -n all "$HOSTNAME: APC UPS Stats for $(date +%-m-%d-%y)"
