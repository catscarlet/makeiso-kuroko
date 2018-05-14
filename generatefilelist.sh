#!/bin/bash

set -euo pipefail
PACKAGE_PATH=/tmp/mountpoint/CentOS7-Everything/Packages
COUNT=0
FOUND=0
NOT_FOUND=0
FILELIST='filelist'
FILELIST_TEMP=`mktemp`
rpm -qa | sort > $FILELIST_TEMP
echo '临时文件：'$FILELIST_TEMP

while read line
    do
        ((COUNT=COUNT+1))
        if [[ -f $PACKAGE_PATH/$line.rpm ]]; then
            #echo '发现文件'$line.rpm
            echo $line.rpm >> $FILELIST
            ((FOUND=FOUND+1))
        else
            ((NOT_FOUND=NOT_FOUND+1))
            echo '未发现文件'$line.rpm
        fi
    done < $FILELIST_TEMP

echo '文件数：'$COUNT
echo '发现文件数:'$FOUND
echo '未发现文件数:'$NOT_FOUND
