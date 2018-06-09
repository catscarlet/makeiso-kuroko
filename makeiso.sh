#!/bin/bash

set -euo pipefail
STARTTIME=`date +%s`

cd $(dirname $(readlink -f $0))

# INPUT
CENTOS7_EVERYTHING_ISO="/tmp/mountpoint/samba/share/CentOS-7-x86_64-Everything-1611.iso"
PAYLOAD_PATH="/root/payload_test/"
CONFIGDIR='boot.template/develop/'

# OUTPUT
OUTPUTFILEDIR="./"
VERSION="v1.0.0"
TIMEZONE='UTC'

usage()
{
    echo "Usage: $0 -d [DEST_DIR=$OUTPUTFILEDIR] -v [RELEASE_VERSION=$VERSION] -s [PAYLOAD_PATH=$PAYLOAD_PATH] -7 [CENTOS7_EVERYTHING_ISO=$CENTOS7_EVERYTHING_ISO] -z [TIMEZONE=$TIMEZONE]" >&2
    exit 1
}

while getopts "d:v:s:7:z:h" arg
do
    case $arg in
        d)
            OUTPUTFILEDIR=$OPTARG
            ;;
        v)
            VERSION=$OPTARG
            ;;
        s)
            PAYLOAD_PATH=$OPTARG
            ;;
        7)
            CENTOS7_EVERYTHING_ISO=$OPTARG
            ;;
        z)
            TIMEZONE=$OPTARG
            ;;
        h)
            usage
            ;;
        *)  #unkonw argument?
            echo "unkonw argument"
            usage
            ;;
    esac
done

# AUTO VARIABLE
VOLUMENAME='PAYLOAD-'`date +'%Y%m%d%H%M'`-$VERSION
VOLUMENAME_SHORT=`expr substr ${VOLUMENAME} 1 16`
FINALNAME=${VOLUMENAME}.iso

# Check
if [[ `createrepo --version 1>/dev/null 2>/dev/null` ]]; then
    echo 'createrepo not installed. Exit.'
    exit 127
fi

if [[ `genisoimage --version 1>/dev/null 2>/dev/null` ]]; then
    echo 'genisoimage not installed. Exit.'
    exit 127
fi

mkdir -p /tmp/mountpoint/CentOS7-Everything/
mountpoint /tmp/mountpoint/CentOS7-Everything/ >/dev/null ||
if [[ !`mountpoint /tmp/mountpoint/CentOS7-Everything/ >/dev/null` ]]; then
    echo 'Try mount '${CENTOS7_EVERYTHING_ISO} && mount -t iso9660 -o loop ${CENTOS7_EVERYTHING_ISO} /tmp/mountpoint/CentOS7-Everything/
fi

if [[ ! -d $PAYLOAD_PATH || ! -f  $PAYLOAD_PATH/install.sh ]]; then
    echo 'Payload not found in '$PAYLOAD_PATH'. Exit.'
    exit 1
fi

echo "----------------------------------------------------------------------------"
echo Start to generate $FINALNAME at  `date -d "1970-01-01 UTC $STARTTIME seconds" +"%Y-%m-%d %T %z"`

echo "----------------------------------------------------------------------------"
rm -rf ./iso_tmp
echo 'Copy CentOS7 DVD framework'
mkdir -p ./iso_tmp/Packages
mkdir -p ./iso_tmp/repodata
mkdir -p ./iso_tmp/PAYLOAD
rsync -au --info=progress2 /tmp/mountpoint/CentOS7-Everything/isolinux iso_tmp/
xargs -n 1 -i cp -rs /tmp/mountpoint/CentOS7-Everything/{} ./iso_tmp < ./filelist/centos_dvd_frame.list

echo -e 'Copy(Actually it'"'"'s "make symbolic links") minimal packages from CentOS7 DVD'
#rsync -a --info=progress2 --files-from=./filelist/minimal.list /tmp/mountpoint/CentOS7-Everything/Packages ./iso_tmp/Packages
xargs -n 1 -i cp -s /tmp/mountpoint/CentOS7-Everything/Packages/{} ./iso_tmp/Packages < ./filelist/minimal.list

echo 'Copy rsync-3.1.2-5.fc26.x86_64.rpm'
rsync -a --info=progress2 rsync-3.1.2-5.fc26.x86_64.rpm ./iso_tmp/Packages

echo 'Copy PAYLOAD'
rsync -a --info=progress2 ${PAYLOAD_PATH} ./iso_tmp/PAYLOAD

echo 'Copy boot files'
rsync -a --info=progress2 $CONFIGDIR/ ./iso_tmp/
sed -i 's/{$TITLE}/'$VOLUMENAME'/' ./iso_tmp/isolinux/isolinux.cfg
sed -i 's/{$TITLE}/'$VOLUMENAME'/' ./iso_tmp/EFI/BOOT/grub.cfg
#sed -i 's/{$VOLUMENAME_SHORT}/'$VOLUMENAME_SHORT'/' ./iso_tmp/isolinux/isolinux.cfg
sed -i 's/{$VOLUMENAME_SHORT}/'$VOLUMENAME_SHORT'/' ./iso_tmp/EFI/BOOT/grub.cfg
escaped_x="$(sed -e 's/[\/&]/\\&/g' <<< "$TIMEZONE")"
ESCAPED_TIMEZONE="${escaped_x}"
sed -i 's/{$TIMEZONE}/'$ESCAPED_TIMEZONE'/' ./iso_tmp/isolinux/payload-develop.cfg

echo 'Create CentOS7 comps.xml'
rsync -a --info=progress2 83b61f9495b5f728989499479e928e09851199a8846ea37ce008a3eb79ad84a0-c7-minimal-x86_64-comps.xml ./iso_tmp/repodata
createrepo -g repodata/83b61f9495b5f728989499479e928e09851199a8846ea37ce008a3eb79ad84a0-c7-minimal-x86_64-comps.xml ./iso_tmp

echo Generate ISO file in $OUTPUTFILEDIR/$FINALNAME
echo Version：$VERSION
echo Volume name：$VOLUMENAME
mkdir -p $OUTPUTFILEDIR
genisoimage \
    -quiet \
    -follow-links \
    -cache-inodes \
    -joliet-long \
    -R -J -T \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -b images/efiboot.img \
    -no-emul-boot \
    -input-charset utf-8 \
    -V $VOLUMENAME_SHORT \
    -o $OUTPUTFILEDIR/$FINALNAME \
    ./iso_tmp

echo 'ISO is generated.'
ls -l --color=auto $OUTPUTFILEDIR/$FINALNAME
ENDTIME=`date +%s`
SPENTTIME=$(($ENDTIME-$STARTTIME))

echo "Finished. Used time: $SPENTTIME seconds"

#clean_up
