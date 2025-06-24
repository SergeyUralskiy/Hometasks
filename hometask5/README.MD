root@vmboard:/Hometasks/Hometasks/hometask5# vagrant ssh

#Все диски подключены и собраны в raid массив

vagrant@ubuntu-focal:~$ lsblk 

NAME   MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0    7:0    0 63.3M  1 loop  /snap/core20/1879
loop1    7:1    0 53.2M  1 loop  /snap/snapd/19122
loop2    7:2    0 91.9M  1 loop  /snap/lxd/24061
sda      8:0    0   40G  0 disk
└─sda1   8:1    0   40G  0 part  /
sdb      8:16   0   10M  0 disk
sdc      8:32   0   10G  0 disk
└─md0    9:0    0   30G  0 raid6 /mnt/raid6
sdd      8:48   0   10G  0 disk
└─md0    9:0    0   30G  0 raid6 /mnt/raid6
sde      8:64   0   10G  0 disk
└─md0    9:0    0   30G  0 raid6 /mnt/raid6
sdf      8:80   0   10G  0 disk
└─md0    9:0    0   30G  0 raid6 /mnt/raid6
sdg      8:96   0   10G  0 disk
└─md0    9:0    0   30G  0 raid6 /mnt/raid6
vagrant@ubuntu-focal:~$

# Сведения raid массива

vagrant@ubuntu-focal:~$ cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md0 : active raid6 sdg[4] sdf[3] sde[2] sdd[1] sdc[0]
      31429632 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>

vagrant@ubuntu-focal:~$ sudo mdadm -D /dev/md0   
/dev/md0:
           Version : 1.2
     Creation Time : Mon Jun 23 07:37:24 2025
        Raid Level : raid6
        Array Size : 31429632 (29.97 GiB 32.18 GB)
     Used Dev Size : 10476544 (9.99 GiB 10.73 GB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Mon Jun 23 07:39:46 2025
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubuntu-focal:0  (local to host ubuntu-focal)
              UUID : a51751e9:28790518:7730a082:64d090e4
            Events : 195

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       3       8       80        3      active sync   /dev/sdf
       4       8       96        4      active sync   /dev/sdg
vagrant@ubuntu-focal:~$

# Обозначаем диск raid массива сбойным

vagrant@ubuntu-focal:~$ sudo mdadm --manage /dev/md0 --fail /dev/sdf  
mdadm: set /dev/sdf faulty in /dev/md0

# Удаляем диск raid массива

vagrant@ubuntu-focal:~$ sudo mdadm --manage /dev/md0 --remove /dev/sdf 
mdadm: hot removed /dev/sdf from /dev/md0

vagrant@ubuntu-focal:~$

vagrant@ubuntu-focal:~$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon Jun 23 07:37:24 2025
        Raid Level : raid6
        Array Size : 31429632 (29.97 GiB 32.18 GB)
     Used Dev Size : 10476544 (9.99 GiB 10.73 GB)
      Raid Devices : 5
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Mon Jun 23 07:45:50 2025
             State : clean, degraded
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubuntu-focal:0  (local to host ubuntu-focal)
              UUID : a51751e9:28790518:7730a082:64d090e4
            Events : 198

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       -       0        0        3      removed
       4       8       96        4      active sync   /dev/sdg
vagrant@ubuntu-focal:~$

#Обнуляем сведения о том, что диск был частью RAID массива

vagrant@ubuntu-focal:~$ sudo mdadm --zero-superblock --force /dev/sdf 

vagrant@ubuntu-focal:~$ sudo mdadm --manage /dev/md0 --add /dev/sdf #Заново добавляем диск в RAID массив
mdadm: added /dev/sdf
vagrant@ubuntu-focal:~$

#Сведения о RAID Массиве

vagrant@ubuntu-focal:~$ sudo mdadm -D /dev/md0 
/dev/md0:
           Version : 1.2
     Creation Time : Mon Jun 23 08:17:42 2025
        Raid Level : raid6
        Array Size : 31429632 (29.97 GiB 32.18 GB)
     Used Dev Size : 10476544 (9.99 GiB 10.73 GB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

#RAID массив восстанавливается

       Update Time : Mon Jun 23 08:24:22 2025
             State : clean, degraded, recovering $ 
    Active Devices : 4
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 1

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

    Rebuild Status : 4% complete

              Name : ubuntu-focal:0  (local to host ubuntu-focal)
              UUID : 4afacade:e75f1e8b:e79f3871:631222a0
            Events : 256

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync   /dev/sdc
       1       8       48        1      active sync   /dev/sdd
       2       8       64        2      active sync   /dev/sde
       5       8       80        3      spare rebuilding   /dev/sdf
       4       8       96        4      active sync   /dev/sdg
vagrant@ubuntu-focal:~$



