#! /bin/bash

# bspnd.sh: Battery Status Push Notifier daemon
# 
# Andy Forceno <t4exanadu@gmail.com>
# 

# Usage:
# 	./bspnd <device> > /dev/null 2>&1 &
# Will run bspnd in the background while supressing output
#
# Alternatively, you can remove the loop and sleep command and execute from cron every n minutes


# I keep this at an amount that I consider safe. 
# Large intervals could cause you to get one (or no) notification(s)
# Personally, I sometimes ignore the 1st notification, so a 2nd is nice :-)
interval="7m"

# Battery percentage when we should send a low battery notification
warn_level="25"

# Used to supress notification if battery is already charged
full_flag=0

# Initial percentage used to determine if battery is charging or discharging
prev_percent=$(acpi | awk '{ gsub(/[^ 0-9]/, ""); print $2 }')

hostname=$(hostname)
echo -e "\nChecking battery status in $interval intervals...\n"

while true;
do
percent=$(acpi | awk '{ gsub(/[^ 0-9]/, ""); print $2 }') 

# Warn user to plug into power source if remaining capacity is below user-defined threshold
# and if the battery level is decreasing
if [ "$percent" -le "$warn_level" ] && [ "$prev_percent" -gt "$percent" ]; then
	/usr/bin/shuttle -p -n "$1" "$hostname: Plug in now" "Battery is at $percent percent"
fi	

# If battery is fully charged and we haven't notified user yet
if [ "$percent" -eq "100" ] && [ "$full_flag" -eq "0" ]; then
	/usr/bin/shuttle -p -n "$1" "$hostname: Battery charged" "Battery is at $percent percent"
	full_flag=1
fi

# If percentage < 100, the battery isn't full so,
# set a flag so future iterations know it's not full
if [ "$percent" -lt "100" ]; then
	full_flag=0
fi

sleep "$interval"

# Save percentage from last iteration
# so we can determine if charge is increasing or decreasing
prev_percent=$percent

done
