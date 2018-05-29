# Makeiso Kuroko

This is a tool for making CentOS7 ISO of yourself.

This only works for CentOS-7-1611. For other version such as 1511, 1708, 1804, and other linux distributions, please wait for more time.

## Requirement

- An avaliable Linux platform. CentOS 7 is prefered, but Ubuntu is also OK
- A CentOS-7-x86_64-Everything-1611.iso image
- genisoimage (A RPM package is included in Everything 1611 iso image)
- createrepo (A RPM package is included in Everything 1611 iso image)
- rsync 3.1.1+ (not included in Everything 1611 iso image, but A RPM package is included in this repository)

## Usage

Basic order：

1. Modify the GLOBAL VARIABLE
2. Copy addtional files you want to install after the system installation to PAYLOAD_PATH. Write a install.sh as the install script.
3. Run makeiso.sh to generate iso file.

### GLOBAL VARIABLE

```
# INPUT

CENTOS7_EVERYTHING_ISO="/tmp/mountpoint/samba/share/CentOS-7-x86_64-Everything-1611.iso"
PAYLOAD_PATH="/root/payload_test/"
CONFIGDIR='boot.template/develop/'

# OUTPUT

OUTPUTFILEDIR="./"
VERSION="v1.0.0"
VOLUMENAME='PAYLOAD-'`date +'%Y%m%d%H%M'`-$VERSION
VOLUMENAME_SHORT=`expr substr ${VOLUMENAME} 1 16`
FINALNAME=${VOLUMENAME}.iso
```

- **CENTOS7_EVERYTHING_ISO** MUST be a accessiable CentOS-7-x86_64-Everything-1611.iso files.
- **PAYLOAD_PATH** is addtional files you want to install after the system installation. After the system installation and auto reboot, `bash install.sh` will be execute automatically once.

### Usage

```
Usage: ./makeiso.sh -d [DEST_DIR=./] -v [RELEASE_VERSION=v1.0.0] -s [PAYLOAD_PATH=/root/payload_test/] -7 [CENTOS7_EVERYTHING_ISO=/root/iso/CentOS-7-x86_64-Everything-1611.iso]
```

And you will get a ISO file. The default username/password is root/root.

Notice that I enabled all the network interface DHCP in kickstart-post-script, so your network configuration in the Install Guide won't work.

* * *

## Project Details

### Packager

```
.
├── 83b61f9495b5f728989499479e928e09851199a8846ea37ce008a3eb79ad84a0-c7-minimal-x86_64-comps.xml
├── boot.template
│   └── develop
│       ├── EFI
│       │   └── BOOT
│       │       └── grub.cfg
│       └── isolinux
│           ├── isolinux.cfg
│           └── payload-develop.cfg
├── d918936f5019be3fb66e9981a28cb2a41477a2963d741d454f79377a22214f43-c7-x86_64-comps.xml
├── filelist
│   ├── centos_dvd_frame.list
│   └── minimal.list
├── generatefilelist.sh
├── makeiso.sh
├── README_cn.md
├── README.md
└── rsync-3.1.2-5.fc26.x86_64.rpm
```

- payload-develop.cfg, Kickstart files, including how to install automatically, the system language, network, root password, etc, A script which will executing after system installation and reboot is also included.
- centos_dvd_frame.list , CentOS-7-1611 DVD frameware files.
- minimal.list , RPM Package needed from Everything-DVD
- generatefilelist.sh , Diff 'installed RPM Package' between the current environment and Everything-DVD. This can be used to generate `your_rpm_payload.list`. **Notice that there is difference between MBR as EFI.**

### ISO

```
.
├── CentOS_BuildTag
├── EFI
│   ├── BOOT
│   │   ├── BOOTX64.EFI
│   │   ├── fonts
│   │   │   ├── TRANS.TBL
│   │   │   └── unicode.pf2
│   │   ├── grub.cfg
│   │   ├── grubx64.efi
│   │   ├── MokManager.efi
│   │   └── TRANS.TBL
│   └── TRANS.TBL
├── EULA
├── GPL
├── images
│   ├── efiboot.img
│   ├── pxeboot
│   │   ├── initrd.img
│   │   ├── TRANS.TBL
│   │   └── vmlinuz
│   └── TRANS.TBL
├── isolinux
│   ├── boot.cat
│   ├── boot.msg
│   ├── grub.conf
│   ├── initrd.img
│   ├── isolinux.bin
│   ├── isolinux.cfg
│   ├── memtest
│   ├── payload-develop.cfg
│   ├── splash.png
│   ├── TRANS.TBL
│   ├── vesamenu.c32
│   └── vmlinuz
├── LiveOS
│   ├── squashfs.img
│   └── TRANS.TBL
├── Packages
│   ├── *.rpm
├── PAYLOAD
│   ├── install.sh
│   ├── *
├── repodata
│   ├── *
│   ├── repomd.xml
│   └── TRANS.TBL
├── RPM-GPG-KEY-CentOS-7
├── RPM-GPG-KEY-CentOS-Testing-7
└── TRANS.TBL
```

### Destination platform root
```
.
├── anaconda-ks.cfg
├── initial-setup-ks.cfg
├── initstart_flag.log
├── initstart.log
├── initstart.sh
├── kickstart-post.log
├── original-ks.cfg
├── PAYLOAD
│   ├── install.sh
│   └── *
├── payload_install.log
└── rpm_qa.list
```

- anaconda-ks.cfg, The kickstart file for this installation at this time.
- initial-setup-ks.cfg, The kickstart file for this installation at this time if you installed Desktop.
- kickstart-post.log The log of the script in POST of kickstart.
- initstart.sh, the script which will be executed after the system installation and reboot, including 'disable YUM source', 'install PAYLOAD', and remove itself from `/etc/rc.d/rc.local`
- initstart_flag.log, the result of executing `initstart.sh`
- initstart.log, the log of `initstart.sh`
- PAYLOAD, Your PAYLOAD
- payload_install.log, the log of PAYLOAD/install.sh
- rpm_qa_develop.list, the result of 'rpm -qa' when the whole installation is finished.

## Build your own ISO

Anything doesn't relate to the CentOS-7-x86_64-Everything ISO is supposed to be put in PAYLOAD and be installed by install.sh

For something relates to the ISO, you can install a new CentOS7 by yourself, and run generatefilelist.sh to generate new rpm filelist, and upgrade kickstart.cfg and comps.xml by yourself. (Or just edit it in the Payload install.sh. It's fine)

This project includes a comps.xml `d918936f5019be3fb66e9981a28cb2a41477a2963d741d454f79377a22214f43-c7-x86_64-comps.xml`, as same as CentOS-7-x86_64-Everything-1611. You should build your own comps.xml and kickstart.cfg for your project.

## Other things

### Idea about naming this 'make linux iso project' Kuroko

This one only works for centos7-1611. The year of 1611 is the year Galileo made naked-eye and telescopic studies of 'sunspots'. Sunspots is called '太阳黑子' in Chinese. '黑子' is also a part of name 'Shirai Kuroko'.

### Idea about naming the directory Payload

I folk project to another team of my company ,and named it 'Payload'. This word means a container, and in game Overwatch, it means vehicle to be escorted. The main idea is this directory is used for containing 3rd-party code.

Butt weight, The word 'Payload' in Team Fortress 2 also means BOMB! Because after I read the code and the project of the other team, I thought those would be a BOMB, it would explode at anytime. ["Bomb is friend! Come, visit friend!"](https://wiki.teamfortress.com/w/images/2/2b/Heavy_cartstaycloseoffense06.wav)

## License

Makeiso-Kuroko is licensed under MIT License.

The default splash image is from ["Toaru Kagaku no Railgun - Shirai Kuroko" by Krukmeister]( https://krukmeister.deviantart.com/art/Toaru-Kagaku-no-Railgun-Shirai-Kuroko-369206997) and it's licensed under a
[Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 License](http://creativecommons.org/licenses/by-nc-nd/3.0/).

If you want to use this project for **commercial purposes**, you should **remove** or **replace** the default splash image.
