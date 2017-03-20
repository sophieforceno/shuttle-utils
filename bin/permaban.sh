#! /bin/bash
#
# Permaban.sh - v1.0
#	by Andy Forceno <andy@aurorabox.tech>
# Each week, make a list of IPs permanently banned by fail2ban, and email it to root@localhost
# Also send whois info for permabanned IPs, and the list of failed authentication attempts
#
# This script requires the ssh-repeater filter for fail2ban. 
# See: http://stuffphilwrites.com/2013/03/permanently-ban-repeat-offenders-fail2ban/
# Or see the comments beneath this script on GitHub
#
# This script works best via cron, for example:
# 58 23  * * 5     /home/user/bin/permaban
# Will send the weekly report on Fridays at 11:58pm
# It is recommended that you check to see when your auth.log is rotated, and have cron execute this just before rotation
#
# I also recommend changing the default action in your jail.local to "action_", like so:
# action = %(action_)s
# That way you won't receive the real-time whois and auth log excerpts from fail2ban on top of the weekly emails from permaban.sh
#

# Address to send log to (if different than $mailto in shuttle-utils.conf)
mailto="root@$HOSTNAME"
# Location of your fail2ban and auth logs
f2b_log="/var/log/fail2ban.log"
auth_log="/var/log/auth.log"

# Grab banned IP's, clean out un-needed info, and nicely format output for easy viewing
permabans=$(grep -w "\[ssh-repeater\] Ban" "$f2b_log" | sed -e 's/,.*\[ssh-repeater\] Ban//g' | awk '{ for (i=1;i<=NF;i+=2) print $3 " " $1 }' | uniq | column -t)
week_begin=$(date --date="7 days ago" +%-m-%d-%y)

# Add all (unique) banned IPs to an array for processing
BANNED=($(echo -e "$permabans" | awk '{ print $1 }' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | uniq))
# Check if there are no banned IPs
if [ ${#BANNED[@]} -ne 0 ]; then
        for ip in "${BANNED[@]}"; do
        	whois=$(whois $ip)
			attempts=$(grep "from $ip" "$auth_log")
		#	echo "permaban: Mailing whois information & login attempts by "$ip" to "$mailto""
            echo -e "$whois\n\n$attempts" | mail -s "Whois information & login attempts for "$ip"" "$mailto"
        done
fi

# If there is a list of banned IPs, then push to $device and mail to $mailto
if [[ -n "$permabans" ]]; then
       echo -e "permaban: Mailing list of permanently banned IPs for the week of ("$week_begin" to $(date +%-m-%d-%y)) to "$mailto""
       echo "$permabans" | mail -s "Permanently banned IPs for week of ("$week_begin" to $(date +%-m-%d-%y))" "$mailto"
       # INFO: Disabled by default
       echo -e "$permabans" | shuttle -p -n chrome "Permanently banned IPs for week of ("$week_begin" to $(date +%-m-%d-%y))"
fi


