#!/bin/bash

set -euo pipefail
PACKAGE_PATH=/tmp/mountpoint/CentOS7-Everything/Packages
COUNT=0
FOUND=0
NOT_FOUND=0
FILELIST='filelist/your_rpm_payload.list'
if [[ -s $FILELIST ]]; then
    FILELIST_NEW='filelist/your_rpm_payload-'`date +'%Y%m%d%H%M%S'`'.list'
    echo "Notice: $FILELIST already exist. Your RPM payload list will be generated in $FILELIST_NEW"
    FILELIST=$FILELIST_NEW
fi
touch $FILELIST
FILELIST_TEMP=`mktemp`
rpm -qa | sort > $FILELIST_TEMP
#echo 'temp file: '$FILELIST_TEMP
echo ''

while read line
    do
        ((COUNT=COUNT+1))
        if [[ -f $PACKAGE_PATH/$line.rpm ]]; then
            #echo 'Found '$line.rpm
            echo $line.rpm >> $FILELIST
            ((FOUND=FOUND+1))
        else
            ((NOT_FOUND=NOT_FOUND+1))
            echo 'Not found: '$line.rpm
        fi
    done < $FILELIST_TEMP

echo 'Count: '$COUNT
echo 'Hit: '$FOUND
echo 'Miss: '$NOT_FOUND
echo ''
echo 'New filelist is generated to: '$FILELIST
