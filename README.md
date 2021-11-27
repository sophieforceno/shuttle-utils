README.md

**SHuttle-utils v1.3 (04-22-18)**

SHuttle-utils is a collection of Bash scripts for monitoring your Linux computer(s). All scripts require `SHuttle`, availble here: https://github.com/sophieforceno/shuttle
Some scripts require additional dependencies: `apcstats.sh` depends on `apcupsd`, `update-all.sh` relies on `dsh` (Distributed Shell), `rdiff-info.sh` depends on `rdiff-backup`, `smartmon-health.sh`,`smartmon-test`, and `smartmon-results.sh` all require `smartmontools`, and `sysmon.sh` requires `lm-sensors` and, optionally, `nvclock`.

Most of these scripts are meant to be run from a central repository/server that logs in to any number of remote hosts via SSH. As a result, full automation of many of the SHuttle-utils scripts requires passwordless SSH authentication and passwordless-sudo access, or some similar security arrangement that allows logging into remote hosts and executing commands as root without having to manually authenticate. For this reason, these scripts are meant to be run from behind a firewall inside a LAN. Lastly, some of these scripts will need to be adapted to your system. For example, `update-all` uses `apt-get`, so it will only work on Ubuntu-based distros.

# Installation:
    git clone https://github.com/sophieforceno/shuttle-utils/
    cd to shuttle-utils/

    # Populate 'hosts' with your hosts, and then:
    mkdir ~/.config/shuttle-utils
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
hosts-check.sh			Helper script to check if hosts are up (must be in same directory as the script that calls it)
ipnotif.sh			Notify when dynamic IP changes (depends on: curl)
permaban.sh            		Push notify of hosts banned by the SSH-repeater filter for Fail2Ban, their auth attempts, and whois info (depends on: fail2ban)
procmon.sh             		Monitor processes and notify of stopped processes
rdiff-notify.sh        		Send push notifications of rdiff-backup session statistics
reboot-notif.sh			Notify when a reboot is requred
smartmon-health.sh		Push SMART drive health info on remote hosts (depends on: smartmontools)
smartmon-test.sh		Run Smartctl long test on remote hosts (depends on: smartmontools)
smartmon-results.sh     	Push smartctl extended test results from remote hosts (depends on: smartmontools)
spaced.sh			Low disk space notification daemon
sysmon.sh               	Notify of high CPU/GPU temperatures and system load
update-all.sh			Run system updates on many hosts via apt-get using dsh (Distributed Shell), and push updated packages list
```


# Notes:
* With the exception of `bspnd.sh` and `hosts-check.sh`, all scripts are meant to be executed via cron (`rdiff-info.sh` has cli usage, too)
* `hosts_check` is called by most of the other scripts, it pings the hosts listed in the shuttle-utils `hosts` file, so the scripts only initiate ssh connections with hosts that are up.
* Most scripts are meant to run from a central repository (server) that logs into remote hosts, except for: `ipnotif.sh`, `procmon.sh`, `permaban.sh`, `rdiff-info.sh`, `apcstats.sh` (for devices with a USB-connected APC UPS), and `bspnd.sh` (for laptops) 
* See individual scripts for more information on each
* SHuttle must be installed and authenticated on all machines that the server will be sending push notifications from (though I provide the option, commented out, to send the notifications as mail)
* If you run many of the scripts, it is recommended that you have their collective output saved to a separate log file such as `/var/log/shuttleutils.log`, like so:
` cron job | /path/to/script/reboot-notif 2>&1 >> /var/log/shuttleutils.log`
* Don't forget to edit shuttle-utils.conf!

Feel free to contribute new scripts or improve existing ones!

Other things I've used SHuttle for:
* Notify me when a torrent downloaded on my laptop is copied to my torrent server
* Notify me when an IP has been permanently banned using fail2ban (see permaban.sh in this repo)
* Send occasional notifications of active connections to my webserver serving a web app
* Send me reminders to do x, where x is a mundane, oft-repeated task I somehow forget to do (cron + SHuttle)


# License:
This program is distributed under the MIT license:

The MIT License (MIT)

Copyright (c) 2021 Sophie Forceno

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
