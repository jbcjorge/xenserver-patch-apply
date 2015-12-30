#!/bin/bash
filename="$1"
server="$2"
dir="${3:-/root}"
pass="$4"
echo "$dir"
mkdir -p $dir/patches/tmp
while read -r line
do
	name=$line
	filename=$(basename "$line")
	extension="${filename##*.}"
	patch="${filename%.*}"
	if [[ ${patch:0:1} != "#" ]]; then
		cd $dir/patches
		cp $filename tmp/
		cd tmp
		unzip $filename
		rm -f $filename
		tmp_uuid=$(xe patch-upload -s $server -u root -pw $passwd file-name=$dir/patches/tmp/$patch.xsupdate 2>&1)
		if [ "$?" -eq "0" ]; then
			uuid=$(echo "$tmp_uuid" | cut -d\  -f2)
		else
			uuid=$(echo "${tmp_uuid##*\n}" | tail -n1 | awk '{print $2}')
		fi
		echo "Applying patch $patch with uuid $uuid"
		xe patch-pool-apply -s $server -u root -pw $passwd uuid=$uuid
		rm -rf $dir/patches/tmp/*
	fi
done < "$filename"
