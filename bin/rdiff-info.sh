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


print_stats () {
	# Find $repo specified on cli in ${REPO_DIRS}
	for i in "${REPO_DIRS[@]}"; do
		# Get backup name
		backup+=($(echo "$i" | grep -iF "$repo"))
		# Get repo that user specified on command line
   		CL_REPO+=($(echo "$i" | grep -i "$repo"))
	done

	for i in "${CL_REPO[@]}"; do
		session_stats=$(sudo ls -lth "$i"/rdiff-backup-data/session_statistics* | awk '{ print $9 }' | head -n1)
	# INFO: Uncomment to receive session stats via email
		# sudo cat "$session_stats" | mail -s "Latest backup stats for $i" "$mailto"	
	done
			if [[ "$output" = "push" ]]; then
			sudo cat "$session_stats" | shuttle -p -n "$device" "Latest backup stats for $backup" 
		elif [[ "$output" = "stdout" ]]; then
			sudo cat "$session_stats"
			echo ""
		fi
}

print_log () {
	# Find $repo specified on cli in ${REPO_DIRS}
	for i in "${REPO_DIRS[@]}"; do
		# Get backup repo_name
		backup+=($(echo "$i" | grep -iF "$repo"))
		# Get repo that user specified on command line
   		CL_REPO+=($(echo "$i" | grep -i "$repo"))
	done
}



case "$1" in
	-o|--stdout)
	output="stdout"
	;;
	-p|--push)
	output="push"
	;;
esac
case "$2" in
	-l|--log)
		print_log
		for i in "${CL_REPO[@]}"; do
			sudo cat "$i"/rdiff-backup-data/backup.log
			#session_log=$(cat "$i"/rdiff-backup-data/backup.log)
		done
		;;
	-s|--stats)
		print_stats
		;;
	-e|--errors)
		print_log
		for i in "${CL_REPO[@]}"; do
			sudo cat "$i"/rdiff-backup-data/backup.log | grep -A4 -E 'exceptions.IOError|exceptions.OSError' 
			echo ""
		done
		;;
	*)
		cat <<- EOF
Usage: rdiff_info.sh info_type data_type repo_name

OPTIONS:
	output_type:
		p | push 		Push notification via SHuttle
		o | output 		Standard output will be used
  	info_type:
		e | errors		Output errors in log of repo_name
		l | log 		Output log of latest backup of repo_name
		s | stats 		Output session statistics for latest backup of repo_name

NOTES:  repo_name is a directory, and can be a subdirectory: rdiff_info.sh stats home/user
	If the user executing rdiff_info.sh does not own the backup repository (backup destination directory) then rdiff_info.sh must be run as root!
	One output_type (-o or -p) and at least one data_type (-e, -l, or -s) are required.
    		rdiff_info.sh -p -s repo_name 		(Push Stats)
	   	rdiff_info.sh -o -e -s			(Standard Output, Errors and Stats)
	Arguments must be in this order: rdiff_info.sh -o or -p first, then -e, l, or -s repo

EOF
	;;
esac

case "$3" in
	-l|--log)
		print_log
	;;
	-s|--stats)
		print_stats
	;;
	-e|--errors)
		print_log
		for i in "${CL_REPO[@]}"; do
			sudo cat "$i"/rdiff-backup-data/backup.log | grep -A4 exceptions.IOError
		done
	;;
esac	

