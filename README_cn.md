# PAYLOAD ISO 打包

这是用于打包 ISO 的工具

本脚本只针对于 CentOS-7-1611.其他版本比如 1511 ， 1708 ，和其他发行版，敬请期待。

## 依赖

- genisoimage
- createrepo
- CentOS-7-x86_64-Everything-1611.iso 镜像
- rsync 3.1.1+

## 使用方式

一般顺序：

1. 修改全局变量
2. 将需要安装的额外文件放入 PAYLOAD_PATH ，编写一个 install.sh 用于在目的机上安装
3. 执行 makeiso3.sh 生成 iso 文件

### 全局变量

```
# 输入

CENTOS7_EVERYTHING_ISO="/tmp/mountpoint/samba/share/CentOS-7-x86_64-Everything-1611.iso"
PAYLOAD_PATH="/root/payload_test/"
CONFIGDIR='boot.template/develop/'

# 输出
OUTPUTFILEDIR="./"
VERSION="v1.0.0"
VOLUMENAME='PAYLOAD-'`date +'%Y%m%d%H%M'`-$VERSION
VOLUMENAME_SHORT=`expr substr ${VOLUMENAME} 1 16`
FINALNAME=${VOLUMENAME}.iso
```

- **CENTOS7_EVERYTHING_ISO** 必须指定为可访问的 CentOS-7-x86_64-Everything-1611.iso
- **PAYLOAD_PATH** 为将要在系统安装完成后安装的包。在目的机系统安装并重启后，会执行一次 `install.sh`

### 调用

```
Usage: ./makeiso3.sh -d [DEST_DIR=./] -v [RELEASE_VERSION=v1.0.0.test] -s [PAYLOAD_PATH=/root/payload_test/]
```

之后你就会得到一个 ISO 文件。默认账号密码为 root/root。

请注意我在 kickstart-post 脚本中启用了所有网口的 DHCP，所以在安装向导配置的网络属性都不会再重启后生效。

* * *

## 文件说明

### 打包程序

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

- payload-develop.cfg ，Kickstart文件，包括系统自动安装的细节设定，系统语言，网络设置，root密码 等。系统重启后会调用的脚本也包含在内。
- centos_dvd_frame.list ，CentOS7 光盘框架基础文件
- payload_dependence.list ，所有需要从 Everything光盘 中获取的 RPM 包
- generatefilelist.sh ，用于从已有环境获取 RPM 包列表并与 Everything 光盘比对的脚本，可用于生成 payload_dependence.list

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

### 目的机 root
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

- anaconda-ks.cfg 本次安装流程生成的 kickstart 文件（启动界面前）
- initial-setup-ks.cfg 本次安装流程生成的 kickstart 文件（启动界面后）
- kickstart-post.log 本次安装过程中 kickstart post 脚本的运行日志
- initstart.sh，在目的机系统安装并重启后会执行的文件，包括'禁用 YUM 源'，'安装 PAYLOAD'，以及将其从`/etc/rc.d/rc.local`中移除
- initstart_flag.log，`initstart.sh` 的运行结果
- initstart.log，`initstart.sh` 的运行日志
- PAYLOAD，PAYLOAD的目录
- payload_install.log，PAYLOAD 下 install.sh 的执行日志
- rpm_qa_develop.list 本次安装过程中安装的 RPM 包

## 开发建议

对于不涉及 CentOS7 安装光盘的操作，建议都放置于 PAYLOAD 目录下，由 install.sh 调用；

对于需要修改 CentOS7 安装光盘的依赖环境的，需要首先在新环境下安装 CentOS7，并使用 generatefilelist.sh 生成新的 rpm filelist，并更新 kickstart 和 comps.xml （或者干脆写到 Payload 的 install.sh 中。 It's fine.）。

项目自带 CentOS-7-x86_64-Everything-1611 的 comps.xml 文件，酌情使用。

## 其他

### 项目名 Kuroko

此项目只支持生成基于 CentOS 7.3.1611 版本。 公历年 1611 是伽利略发表对太阳黑子观察相关的年份。黑子。

### 目录名 Payload

我将这个项目 folk 给了公司的另一个项目组，并给这个目录取名 Payload 。Payload 意思是装载，在游戏 守望先锋 中，一般都是指 推车。这个目录的意思就是用来承载第三方的额外包。

但是，Payload 在游戏 TF2 中意味着 Bomb。我看了另一个组的代码之后，我觉得这就是个 Bomb ["Bomb is friend! Come, visit friend!"](https://wiki.teamfortress.com/w/images/2/2b/Heavy_cartstaycloseoffense06.wav)

## License

MIT License
