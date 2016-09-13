#!/bin/bash
_SCRIPTDIR="$( cd "$( dirname "$0" )" && pwd )"

syncFiles=$1

# get the sources directory and destination directory
i=0
while read -r line || [[ -n $line ]]; do
	if [ $i == 0 ]; then
		sources=`echo ${line} | awk -F ':' '{print $2}'`
	elif [ $i == 1 ]; then
		destination=`echo ${line} | awk -F ':' '{print $2}'`
	fi
	i=`expr $i + 1`
done < $syncFiles

# ask use for sure copy or not
echo "Sure copy files from ${sources} to ${destination} (y/n):"
read -s -n 1 key
echo $key
if [[ $key != 'y' ]]; then
	echo 'Exit.'
	exit
fi

# iterate the files or directories, and do copy
j=-1
while read -r line || [[ -n $line ]]; do
	j=`expr $j + 1`
	if [ $j == 0 ] || [ $j == 1 ] || [[ $line = '' ]]; then
		continue
	fi

	if [[ $line =~ '->' ]]; then
		src=`echo ${line} | awk -F '->' '{print $1}'`
		dst=`echo ${line} | awk -F '->' '{print $2}'`
	else
		src=$line
		dst=$line
	fi
	if [[ `echo -n $dst | tail -c 1` != '/' ]]; then
		$dst=`dirname $dst`
	fi
	echo "copying... ${src} -> ${dst}"

	# create the destination directory if not exists. 'man test' for more details
	destinationDir="${destination}/${dst}"
	[ -d $destinationDir ] || mkdir -p $destinationDir

	# copy the files from source to destination
	sourceFilePath="${sources}/${src}"
	if [ -d $sourceFilePath ]; then
		cp -R $sourceFilePath $destinationDir
	else
		cp $sourceFilePath $destinationDir
	fi
done < $syncFiles

echo 'Done.'
