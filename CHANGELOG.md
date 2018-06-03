1.2 2018-06-03

- Now boot splash screen is supported. Both Legacy(MBR) and EFI are supported.
- Add ARG $CENTOS7_EVERYTHING_ISO path. Now not have to edit the GLOBAL VARIABLE of $CENTOS7_EVERYTHING_ISO.
- Add ARG $TIMEZONE. Now not have to edit the kickstart file to set Time Zone.
- Minor bug fixes.

1.1 2018-05-21

- Now EFI support is conformed.
- Delete a lot unnecessary file-copy in `minimal.list`. I have no idea why and how I added those unused files into filelist. Even the file is in the iso, they wouldn't be installed because they are not included in the comps.xml or kickstart. I just have no idea how did I make this mistake. For now the output iso file will be thinner (reduced about 20 MB).

1.0.1 2018-05-17

- Fix file name reference error.

1.0.0 2018-05-16

- Initial release
