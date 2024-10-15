folder_path=$1
fullness_limit=$2
cut_files_count=$3

if [ -d $folder_path ] && [[ "$fullness_limit" =~ ^[0-9]+$ ]] && [[ "$cut_files_count" =~ ^[0-9]+$ ]]
then
	folder_fullness=$( df --output=pcent $folder_path | grep -v Use | sed 's/%//')
	if [ $folder_fullness -gt $fullness_limit ];
	then
		if [ -n "$(ls -A "$folder_path")" ]; then
			find $folder_path -type f | sort -r | tail -$3 | xargs tar cvfz backup.tar.gz --remove-files
		else
			echo "folder is empty"
		fi
	fi
else
	echo 'parameters are not good'
fi


