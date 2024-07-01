#! /bin/bash

# rdiff_info.sh: rdiff-backup session information
#	by Sophie Forceno

# Usage Notes:
# It is recommended to execute this script after each cron backup job:
# rdiff-backup -v5 user@host::/home /backup/home/user && sudo /home/user/scripts/bin/rdiff_info.sh -p -s home/user > /dev/null 2>&1
# Upon successful backup of user@host's home/ directory, run rdiff_info.sh to push latest session statistics for backup of /home/user

# If the user executing rdiff_info.sh does not own the backup repositories (backup destination dirs) then rdiff_info.sh must be run as root!
#

if [ -e "$HOME"/.config/shuttle-utils/shuttle-utils.conf ]; then
	source "$HOME"/.config/shuttle-utils/shuttle-utils.conf
else
	echo "SHuttle-utils: Error: No config file found!"
	exit 1
fi

repo="${BASH_ARGV[0]}"
dir_1="/backups"
dir_2="/media/backups"
# Include the full path to each backup repository 
# Each repo specified here must contain an rdiff-backup-data directory
# Feel free to use $dir_n variables, to reduce line length of the array
REPO_DIRS=("$dir_1/machine1/root" "$dir_1/machine2/home" "$dir_1/machine2/root" "$dir_2/music")


find_repo () {
	# Find $repo specified on cli in ${REPO_DIRS}
	for i in "${REPO_DIRS[@]}"; do
		repo_path+=($(echo "$i" | grep -iF "$repo"))
	done
}

# Sends log, error, and stats in a single email
mail_all () {
	session_log="$repo_path/rdiff-backup-data/backup.log"
	session_stats=$(sudo ls -lt "$repo_path"/rdiff-backup-data/session_statistics* | awk '{ print $9 }' | head -n1)
	session_stats=$(cat "$session_stats")
	error_log=$(sudo grep -E 'exceptions.OSError|exceptions.IOError' "$repo_path"/rdiff-backup-data/backup.log | sed -e 's/.*] \(.*\)raised.*/\1/' -e "s/'//g" | sort | uniq)
	repo_dash=$(echo "$repo" | sed 's/\//-/g')

	if [[ -z "$error_log" ]]; then
		error_log="No errors during backup\n"
	fi

	sudo cp "$session_log" /tmp/$repo_dash.txt
	cd /tmp
	zip -9 $repo_dash.txt.zip $repo_dash.txt >/dev/null 2>&1
	filesize=$(du -b $repo_dash.txt.zip | awk '{ print $1 }')
	attachlimit="35000000"

	if [[ "$filesize" -gt "$attachlimit" ]]; then
		echo -e "Attachment ($filesize) exceeds size limit. Attachment not included.\n$error_log\n\n$session_stats" | mail -s "$repo: Latest backup error log" "$mailto"
	else
		#echo "Sending compressed log email... (Attachment is $filesize)"
		echo -e "$error_log\n\n$session_stats" | mutt -s "$repo: Latest backup log" "$mailto" -a "/tmp/$repo_dash.txt.zip"
		rm /tmp/$repo_dash.txt /tmp/$repo_dash.txt.zip
	fi
}

get_stats () {
	session_stats=$(sudo ls -lt "$repo_path"/rdiff-backup-data/session_statistics* | awk '{ print $9 }' | head -n1)

	if [[ "$output" = "push" ]]; then
		sudo cat "$session_stats" | /home/sophie/scripts/python/spush.py "$repo: Latest backup stats" "backup"
		rc=$?
		if [[ "$rc" -ne 0 ]]; then
			echo -e "$session_stats" | mail -s "$repo: Backup statistics push notification failed!!" root
		fi
	    # sudo cat "$session_stats" | shuttle -p -n "$device" "Latest backup stats for $repo_path"
	elif [[ "$output" = "stdout" ]]; then
		sudo cat "$session_stats"
		echo ""
	elif [[ "$output" = "mail" ]]; then
		cat "$session_stats" | mail -s "$repo: Latest backup stats" $mailto
	fi
}

get_log () {
	session_log="$repo_path/rdiff-backup-data/backup.log"

	if [[ "$output" = "mail" ]]; then
		repo_dash=$(echo "$repo" | sed 's/\//-/g')
		#echo "Compressing log file..."
		sudo cp "$session_log" /tmp/$repo_dash.txt
		cd /tmp
		zip -9 $repo_dash.txt.zip $repo_dash.txt >/dev/null 2>&1
		filesize=$(du -b $repo_dash.txt.zip | awk '{ print $1 }')
		attachlimit="35000000"

		if [[ "$filesize" -gt "$attachlimit" ]]; then
			echo -e "Attachment ($filesize) exceeds size limit. Attachment not included.\n$error_log\n$session_stats" | mail -s "$repo: Latest backup log" "$mailto"
	 	else
			# echo "Sending compressed log email... (Attachment is $filesize)"
			echo | mutt -s "Latest backup log for $repo" "$mailto" -a "/tmp/$repo_dash.txt.zip"
			rm /tmp/$repo_dash.txt /tmp/$repo_dash.txt.zip
		fi
	elif [[ "$output" = "stdout" ]]; then
		cat "$session_log"
	# No pushing of logs
	fi
}

get_errors () {
	error_log=$(sudo grep -E 'exceptions.OSError|exceptions.IOError' "$repo_path"/rdiff-backup-data/backup.log | sed -e 's/.*] \(.*\)raised.*/\1/' -e "s/'//g" | sort | uniq)
	bytecount=$(echo "$error_log" | wc -c)

	if [[ "$output" = +(mail|stdout) && "$bytecount" -ge 10000 ]]; then
		cd /tmp
		echo "$error_log" >> $repo_dash.txt
		zip -9 $repo_dash.txt.zip $repo_dash.txt >/dev/null 2>&1
		echo | mutt -s "$repo: Backup error log" "$mailto" -a "/tmp/$repo_dash.txt.zip"
		rm /tmp/$repo_dash.txt /tmp/$repo_dash.txt.zip
	elif [[ "$output" = "stdout" && -n "$error_log" && "$bytecount" -lt 10000 ]]; then
		echo "$error_log"
	elif [[ "$output" = "mail" && -n "$error_log" && "$bytecount" -lt 10000 ]]; then
		echo "$error_log" | mail -s "$repo: Backup error log" "$mailto"
	elif [[ -z "$error_log" ]]; then
		echo "No errors during this repo backup session"
	fi
}

check_root() {
	if [ "$EUID" -ne 0 ]; then
	  		echo "rdiff-info.sh must be run as root."
	  	exit
		fi
}

case "$1" in
	-o|--stdout)
	check_root
	output="stdout"
	;;
	-p|--push)
	check_root
	output="push"
	;;
	-m|--mail)
	check_root
	output="mail"
esac

case "$2" in
	-l|--log)
		find_repo
		get_log
		;;
	-s|--stats)
		find_repo
		get_stats
		;;
	-e|--errors)
		find_repo
		get_errors
		;;
	-a|--all)
		find_repo
		mail_all
		;;
	*)
		cat <<- EOF
	Usage: rdiff_info.sh info_type data_type repo_name
		
	OPTIONS:
		output_type:
			m | mail		Send an email with info_type (requires 'mutt', logs are zip attachments)
			o | output 		Standard output will be used
			p | push 		Push notification (requires 'SHuttle' or your own script)

		info_type:
			a | all			Output everything, errors, logs, and stats (output_type -m only)
			e | errors		Output errors in log of repo_name
			l | log 		Output log of latest backup of repo_name
			s | stats 		Output session statistics for latest backup of repo_name
		
	NOTES:  repo_name is a directory, and can be a subdirectory: rdiff_info.sh stats home/user
			If the user executing rdiff_info.sh does not own the backup repository (backup destination directory) then rdiff_info.sh must be run as root!
			One output_type (-o or -p) and at least one data_type (-e, -l, or -s) are required.
		    		rdiff_info.sh -p -s repo_name 		(Push Stats)
			   	rdiff_info.sh -o -e -s			(Standard Output, Errors and Stats)
			   	rdiff_info.sh -m -a			(Mail, Errors, Logs, and Stats)
			Arguments must be in this order: rdiff_info.sh -o or -p first, then -e, l, or -s repo
		
	EOF
	;;
esac

case "$3" in
	-l|--log)
		get_log
	;;
	-s|--stats)
		get_stats
	;;
	-e|--errors)
		get_errors
	;;
esac

exit 0

