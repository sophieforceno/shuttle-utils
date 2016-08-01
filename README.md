README.md

**SHuttle-utils v0.9.8-(080116)**

Shuttle-utils is a collection of Bash scripts for monitoring your Linux computer(s). They require SHuttle, availble here: https://github.com/andyforceno/shuttle


# Installation:
    git clone https://github.com/andyforceno/shuttle-utils/
    cd to shuttle-utils/
    # Find all files in dir without file extension and set executable bit
    find . -type f ! -name ".*" -maxdepth 1 -exec chmod +x {} \;
    # Populate .hosts with your hosts, and then:
    mkdir ~/.config/shuttle-utils
    cp .hosts $HOME/.config/shuttle-utils
    # Edit the config file in a text editor
    nano shuttle-utils.conf
    cp shuttle-utils.conf ~/.config/shuttle-utils


``` 
shuttle-utils contains the following scripts:

back2ntfs			Create .tar archives, transfer to NAS device, and verify checksums
bspnd				Battery charge status push notifier daemon
checklogs			Notify if system logs are greater than some size
hostname-isup		Notify if host stops responding to pings
hosts_check			Helper script to check if hosts are up (must be in same directory as the scripts that call it)
					Used by: back2ntfs, checklogs, smartmon, smartmon_long, spaced
ipnotif				Notify when dynamic IP changes (requires curl)
reboot_notif		Notify when a reboot is requred
smartmon			Push SMART diagnostic info about drives on remote hosts
smartmon_long		Run Smartctl long test on remote hosts and send pushes of results
spaced				Low disk space notification daemon
sysmon              NEW! Notify of high CPU/GPU temperatures and system load
update_all			Run system updates via apt-get using dsh (Distributed Shell), and push updated packages list
```


# Notes:
* With the exception of `bspnd` and `hosts_check`, all scripts are meant to be executed via cron
* If you run many of the scripts, it is recommended that you have their collective output
saved to a separate log file, such as /var/log/shuttle-utils.log, such as:
` "$HOME"/scripts/bin/reboot_notif 2>&1 >> /var/log/shuttle-utils.log`
* See the individual scripts for more information on each
* Don't forget to edit shuttle-utils.conf!

Feel free to contribute new scripts or improve existing ones!

Other things I've used SHuttle for:
* Notify me when a torrent downloaded on my laptop is copied to my torrent server
* Notify me when GPU/CPU temperature or system load cross a certain threshold 
* Send me reminders to do X, where X is a mundane, oft-repeated task I somehow forget to do


# Changelong:
v0.9.8-(080116):
* Now storing all user config scripts in ~/.config/shuttle-utils
* New script, sysmon! Notify of high Nvidia GPU temp, CPU temp, and system load
* Re-wrote update_all to use dsh (Distributed Shell, Dancers' SHell) to run concurrent updates
* Moved (almost) all user-defined variables to shuttle-utils.conf
* Smartmon now accepts an array of drives (for now, drives must be the same on all devices)
* Small improvements to all scripts

v0.9.7-(072416):
* Re-wrote sysmon script (and forgot to include it, oops!)
* Fixed bugs in smartmon_long, re-added to repo 
* Added update_all (requires dsh, Distributed Shell)
* Most scripts now have sending of mail disabled by default
* hosts_check now reads hostnames from a newline-delimited list ~/.config/shuttle-utils/.hosts
* Fixed mumerous bugs and code inconsistencies across scripts


# License:
This program is distributed under the MIT license:

The MIT License (MIT)

Copyright (c) 2016 Andy Forceno <andy@aurorabox.tech>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
