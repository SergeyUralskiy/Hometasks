1. название выполняемого задания - Стенд ZFS
2. текст задания;
Определить алгоритм с наилучшим сжатием:
Определить какие алгоритмы сжатия поддерживает zfs
(gzip, zle, lzjb, lz4);
создать 4 файловых системы на каждой применить свой
алгоритм сжатия;
для сжатия использовать либо текстовый файл, либо группу
файлов.
Определить настройки пула.
С помощью команды zfs import собрать pool ZFS.
Командами zfs определить настройки:
- размер хранилища;
- тип pool;
- значение recordsize;
- какое сжатие используется;
- какая контрольная сумма используется.
Работа со снапшотами:
- скопировать файл из удаленной директории;
- восстановить файл локально. zfs receive;
- найти зашифрованное сообщение в файле secret_message.
3. описание команд и их вывод содержатся в файле lvm-2.log;
root@lvm-2:/# cat lvm-2.log
Script started on 2025-07-03 16:19:56+00:00 [TERM="xterm-256color" TTY="/dev/pts/1" COLUMNS="237" LINES="63"]
root@lvm-2:/# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   25G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   23G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0 11.5G  0 lvm  /
sdb                         8:16   0  512M  0 disk
sdc                         8:32   0  512M  0 disk
sdd                         8:48   0  512M  0 disk
sde                         8:64   0  512M  0 disk
sdf                         8:80   0  512M  0 disk
sdg                         8:96   0  512M  0 disk
sdh                         8:112  0  512M  0 disk
sdi                         8:128  0  512M  0 disk
sr0                        11:0    1 1024M  0 rom
root@lvm-2:/# zpool create otus1 mirror /dev/sdb /dev/sdc
root@lvm-2:/#
root@lvm-2:/# zpool create otus2 mirror /dev/sdd /dev/sde
root@lvm-2:/#
root@lvm-2:/# zpool create otus3 mirror /dev/sdf /dev/sdg
root@lvm-2:/#
root@lvm-2:/# zpool create otus4 mirror /dev/sdh /dev/sdi
root@lvm-2:/#
root@lvm-2:/# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   111K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   111K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   111K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M   134K   480M        -         -     0%     0%  1.00x    ONLINE  -
root@lvm-2:/#
root@lvm-2:/# zpool status
  pool: otus1
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

errors: No known data errors
root@lvm-2:/#
root@lvm-2:/# zfs set compression=lzjb otus1
root@lvm-2:/#
root@lvm-2:/# zfs set compression=lz4 otus2
root@lvm-2:/#
root@lvm-2:/# zfs set compression=gzip-9 otus3
root@lvm-2:/#
root@lvm-2:/# zfs set compression=zle otus4
root@lvm-2:/#
root@lvm-2:/# zfs get all | grep compression
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local
root@lvm-2:/#
root@lvm-2:/# for i in {1..4}; do wget -P /otus$i
> https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
wget: missing URL
Usage: wget [OPTION]... [URL]...

Try `wget --help' for more options.
bash: https://gutenberg.org/cache/epub/2600/pg2600.converter.log: No such file or directory
wget: missing URL
Usage: wget [OPTION]... [URL]...

Try `wget --help' for more options.
bash: https://gutenberg.org/cache/epub/2600/pg2600.converter.log: No such file or directory
wget: missing URL
Usage: wget [OPTION]... [URL]...

Try `wget --help' for more options.
bash: https://gutenberg.org/cache/epub/2600/pg2600.converter.log: No such file or directory
wget: missing URL
Usage: wget [OPTION]... [URL]...

Try `wget --help' for more options.
bash: https://gutenberg.org/cache/epub/2600/pg2600.converter.log: No such file or directory
root@lvm-2:/#
root@lvm-2:/# for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
--2025-07-03 16:25:37--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41158891 (39M) [text/plain]
Saving to: ‘/otus1/pg2600.converter.log’

pg2600.converter.log                                         27%[====================================>                                                                                                    ]  10.65M  17.8KB/s    in 8m 57s

2025-07-03 16:34:35 (20.3 KB/s) - Connection closed at byte 11168979. Retrying.

--2025-07-03 16:34:36--  (try: 2)  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 206 Partial Content
Length: 41158891 (39M), 29989912 (29M) remaining [text/plain]
Saving to: ‘/otus1/pg2600.converter.log’

pg2600.converter.log                                        100%[+++++++++++++++++++++++++++++++++++++===================================================================================================>]  39.25M   118KB/s    in 4m 1s

2025-07-03 16:38:38 (121 KB/s) - ‘/otus1/pg2600.converter.log’ saved [41158891/41158891]

--2025-07-03 16:38:38--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41158891 (39M) [text/plain]
Saving to: ‘/otus2/pg2600.converter.log’

pg2600.converter.log                                        100%[========================================================================================================================================>]  39.25M   179KB/s    in 5m 49s

2025-07-03 16:44:29 (115 KB/s) - ‘/otus2/pg2600.converter.log’ saved [41158891/41158891]

--2025-07-03 16:44:29--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41158891 (39M) [text/plain]
Saving to: ‘/otus3/pg2600.converter.log’

pg2600.converter.log                                        100%[========================================================================================================================================>]  39.25M  50.0KB/s    in 5m 54s

2025-07-03 16:50:24 (113 KB/s) - ‘/otus3/pg2600.converter.log’ saved [41158891/41158891]

--2025-07-03 16:50:24--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41158891 (39M) [text/plain]
Saving to: ‘/otus4/pg2600.converter.log’

pg2600.converter.log                                         55%[===========================================================================>                                                             ]  21.81M  16.5KB/s    in 18m 47s

2025-07-03 17:09:12 (19.8 KB/s) - Connection closed at byte 22868175. Retrying.

--2025-07-03 17:09:13--  (try: 2)  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 206 Partial Content
Length: 41158891 (39M), 18290716 (17M) remaining [text/plain]
Saving to: ‘/otus4/pg2600.converter.log’

pg2600.converter.log                                        100%[++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++============================================================>]  39.25M   448KB/s    in 14s

2025-07-03 17:09:28 (1.24 MB/s) - ‘/otus4/pg2600.converter.log’ saved [41158891/41158891]

root@lvm-2:/# ls -l /otus*
/otus1:
total 22109
-rw-r--r-- 1 root root 41158891 Jul  2 07:31 pg2600.converter.log

/otus2:
total 18013
-rw-r--r-- 1 root root 41158891 Jul  2 07:31 pg2600.converter.log

/otus3:
total 10970
-rw-r--r-- 1 root root 41158891 Jul  2 07:31 pg2600.converter.log

/otus4:
total 40226
-rw-r--r-- 1 root root 41158891 Jul  2 07:31 pg2600.converter.log
root@lvm-2:/#
root@lvm-2:/# zfs list
NAME    USED  AVAIL  REFER  MOUNTPOINT
otus1  21.8M   330M  21.6M  /otus1
otus2  17.8M   334M  17.6M  /otus2
otus3  10.9M   341M  10.7M  /otus3
otus4  39.5M   313M  39.3M  /otus4
root@lvm-2:/#
root@lvm-2:/# zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.82x                  -
otus2  compressratio         2.23x                  -
otus3  compressratio         3.66x                  -
otus4  compressratio         1.00x                  -
root@lvm-2:/#
root@lvm-2:/# wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
--2025-07-04 08:34:08--  https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download
Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 108.177.14.132, 2a00:1450:4010:c0f::84
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|108.177.14.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/octet-stream]
Saving to: ‘archive.tar.gz’

archive.tar.gz                                              100%[========================================================================================================================================>]   6.94M  4.83MB/s    in 1.4s

2025-07-04 08:34:18 (4.83 MB/s) - ‘archive.tar.gz’ saved [7275140/7275140]

root@lvm-2:/#
root@lvm-2:/# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
root@lvm-2:/# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
        (Note that they may be intentionally disabled if the
        'compatibility' property is set.)
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                    ONLINE
          mirror-0              ONLINE
            /zpoolexport/filea  ONLINE
            /zpoolexport/fileb  ONLINE
root@lvm-2:/#
root@lvm-2:/# zpool import -d zpoolexport/ otus
root@lvm-2:/#
root@lvm-2:/# zpool status
  pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
config:

        NAME                    STATE     READ WRITE CKSUM
        otus                    ONLINE       0     0     0
          mirror-0              ONLINE       0     0     0
            /zpoolexport/filea  ONLINE       0     0     0
            /zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: otus1
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

errors: No known data errors
root@lvm-2:/#
root@lvm-2:/# zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      12932831491073884470           -
otus  autotrim                       off                            default
otus  compatibility                  off                            default
otus  bcloneused                     0                              -
otus  bclonesaved                    0                              -
otus  bcloneratio                    1.00x                          -
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local
otus  feature@redaction_bookmarks    disabled                       local
otus  feature@redacted_datasets      disabled                       local
otus  feature@bookmark_written       disabled                       local
otus  feature@log_spacemap           disabled                       local
otus  feature@livelist               disabled                       local
otus  feature@device_rebuild         disabled                       local
otus  feature@zstd_compress          disabled                       local
otus  feature@draid                  disabled                       local
otus  feature@zilsaxattr             disabled                       local
otus  feature@head_errlog            disabled                       local
otus  feature@blake3                 disabled                       local
otus  feature@block_cloning          disabled                       local
otus  feature@vdev_zaps_v2           disabled                       local
root@lvm-2:/#
root@lvm-2:/#
root@lvm-2:/# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
root@lvm-2:/#
root@lvm-2:/# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
root@lvm-2:/#
root@lvm-2:/# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
root@lvm-2:/#
root@lvm-2:/#
root@lvm-2:/# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
root@lvm-2:/#
root@lvm-2:/#
root@lvm-2:/# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
root@lvm-2:/#
root@lvm-2:/#
root@lvm-2:/# wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
[1] 18760
root@lvm-2:/#
Redirecting output to ‘wget-log’.
^C
[1]+  Done                    wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI
root@lvm-2:/# wget -O otus_task2.file --no-check-certificate 'https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download'
--2025-07-04 08:40:49--  https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 108.177.14.132, 2a00:1450:4010:c0f::84
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|108.177.14.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5432736 (5.2M) [application/octet-stream]
Saving to: ‘otus_task2.file’

otus_task2.file                                             100%[========================================================================================================================================>]   5.18M  6.53MB/s    in 0.8s

2025-07-04 08:40:52 (6.53 MB/s) - ‘otus_task2.file’ saved [5432736/5432736]

root@lvm-2:/# zfs receive otus/test@today < otus_task2.file
root@lvm-2:/#
root@lvm-2:/#
root@lvm-2:/# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
root@lvm-2:/#
root@lvm-2:/#
root@lvm-2:/# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/

root@lvm-2:/# exit

4. особенности проектирования и реализации решения;
Создание дополнительных дисков было выполнено вручную через графический интерфейс VirtualBox

5. заметки, если считаете, что имеет смысл их зафиксировать в репозитории.
