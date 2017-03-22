README.md

**SHuttle-utils v1.1 (03-21-17)**

SHuttle-utils is a collection of Bash scripts for monitoring your Linux computer(s). All scripts require `SHuttle`, availble here: https://github.com/andyforceno/shuttle
Some scripts require additional dependencies: `apcstats` depends on `apcupsd`, `update_all` relies on `dsh` (Distributed Shell), `rdiff_notify` depends on `rdiff-backup`, `smartmon_health`,`smartmon_test`, and `smartmon_results` all require `smartmontools`, and `sysmon` requires `lm-sensors` and, optionally, `nvclock`.

Most of these scripts are meant to be run from a central repository/server that logs in to any number of remote hosts via SSH. As a result, full automation of many of the SHuttle-utils scripts requires passwordless SSH authentication and passwordless-sudo access, or some similar security arrangement that allows logging into remote hosts and executing commands as root without having to manually authenticate. For this reason, these scripts are meant to be run from behind a firewall inside a LAN. Lastly, some of these scripts will need to be adapted to your system. For example, `update_all` uses `apt-get`, so it will only work on Ubuntu-based distros.

# Installation:
    git clone https://github.com/andyforceno/shuttle-utils/
    cd to shuttle-utils/

    # Populate 'hosts' with your hosts, and then:
    mkdir ~/.config/shuttle-utilss
    cp hosts $HOME/.config/shuttle-utils

    # Edit the config file in a text editor
    nano shuttle-utils.conf
    cp shuttle-utils.conf ~/.config/shuttle-utils
    # Configure cron jobs for the scripts, and watch the magic happen!


``` 
shuttle-utils contains the following scripts:

apcstats.sh 			Pushes stats for APC UPSes (depends on: apcupsd)
bspnd.sh			Battery charge status push notifier daemon (for laptops)
checklogs.sh			Notify if system logs are greater than some size
hostname-isup.sh		Notify if host stops responding to pings
hosts_check.sh			Helper script to check if hosts are up (must be in same directory as the script that calls it)
				Used by: back2ntfs, checklogs, reboot_notif, smartmon, smartmon_long, spaced, sysmon, update_all
ipnotif.sh			Notify when dynamic IP changes (depends on: curl)
permaban.sh            		Push notify of hosts banned by the SSH-repeater filter for Fail2Ban, their auth attempts, and whois info (depends on: fail2ban)
procmon.sh             		Monitor processes and notify of stopped processes
rdiff_notify.sh        		Send push notifications of rdiff-backup session statistics
reboot_notif.sh			Notify when a reboot is requred
smartmon_health.sh		Push SMART drive health info on remote hosts (depends on: smartmontools)
smartmon_test.sh		Run Smartctl long test on remote hosts (depends on: smartmontools)
smartmon_results.sh     	Push smartctl extended test results from remote hosts (depends on: smartmontools)
spaced.sh			Low disk space notification daemon
sysmon.sh               	Notify of high CPU/GPU temperatures and system load
update_all.sh			Run system updates on many hosts via apt-get using dsh (Distributed Shell), and push updated packages list
```


# Notes:
* With the exception of `bspnd` and `hosts_check`, all scripts are meant to be executed via cron
* Most scripts are meant to be run from a central repository (server), with the exception of: `ipnotif`, `procmon`, `permaban`, `rdiff_notify`, `apcstats` (for devices with a UPS connected), and `bspnd` (for laptops), 
* See individual scripts for more information on each
* SHuttle must be installed on all machines that the server will be sending push notifications from
* If you run many of the scripts, it is recommended that you have their collective output saved to a separate log file such as `/var/log/shuttle-utils.log`, like so:
` cron job | /path/to/script/reboot_notif 2>&1 >> /var/log/shuttle-utils.log`
* Don't forget to edit shuttle-utils.conf!

Feel free to contribute new scripts or improve existing ones!

Other things I've used SHuttle for:
* Notify me when a torrent downloaded on my laptop is copied to my torrent server
* Notify me when an IP has been permanently banned using fail2ban (see permaban.sh in this repo)
* Send occasional notifications of active connections to my webserver
* Send me reminders to do X, where X is a mundane, oft-repeated task I somehow forget to do (cron + SHuttle)


# License:
This program is distributed under the MIT license:

The MIT License (MIT)

Copyright (c) 2017 Andy Forceno <andy@aurorabox.tech>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
