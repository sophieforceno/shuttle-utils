README.md

**SHuttle-utils v0.9-(062016) - First public release!**

Shuttle-utils is a collection of Bash scripts for monitoring your Linux computer(s). They require SHuttle, availble here: https://github.com/andyforceno/shuttle


# Installation:
    git clone https://github.com/andyforceno/shuttle-utils/
    cd to shuttle-utils/
    chmod +x * (lazily chmod all files in dir, you should chmod -x README.md afterwards)
	 
In these scripts, SHuttle is executed with no specified path, this means you will either have to create a symbolic link to SHuttle in /usr/bin
or put SHuttle's path to your $PATH environment variable. This is typically done by adding 'PATH="path/to/dir:$PATH' to your user's .bashrc or .profile files.
You will have to repeat whichever method you choose on any remote devices you specify in the hosts_check script. 

``` 
shuttle-utils contains the following scripts:

bspnd				Battery charge status push notifier daemon
checklogs			Notify if system logs are greater than some size
hostname-isup		Notify if host stops responding to pings
hosts_check			Helper script to check if hosts are up (must be in same directory as the scripts that call it)
					Used by: checklogs, smartmon, smartmon_long, spaced
ipnotif				Notify when dynamic IP changes (requires curl)
reboot_notif		Notify when a reboot is requred
smartmon			Push SMART diagnostic info about drives on remote hosts
smartmon_long		Run Smartctl long test on remote hosts and send pushes of results
spaced				Low disk space notification daemon
```


# Notes:
With the exception of bspnd and hosts_check, all scripts are meant to be executed via cron

See the individual scripts for more information on each

Feel free to contribute new scripts or improve existing ones!

Other things I've used SHuttle for:
* Notify me when checksum verifications for .tar backups fail
* Notify me when a torrent downloaded on my laptop is copied to my torrent server
* Notify me when GPU/CPU temperature or system load cross a certain threshold 
* Send me reminders to do X, where X is a mundane, oft-repeated task I somehow forget to do


# License:
This program is distributed under the MIT license:

The MIT License (MIT)

Copyright (c) 2016 Andy Forceno <andy@aurorabox.tech>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.