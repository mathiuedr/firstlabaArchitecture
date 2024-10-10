papka=$( df --output=pcent $1 | grep -v Use | sed 's/%//')
echo $papka
if [ $papka -gt $2 ];
then
	echo 'good';
	find $1 -maxdepth 1 -type f | sort | tail -$3 | xargs tar cvfz backup.tar.gz --remove-files
else
	echo 'not good';
fi
