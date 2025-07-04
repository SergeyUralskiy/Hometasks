#!/bin/bash
set -e

# 1. Просмотр дисков
lsblk

# 2. Обновление системы
apt update && apt upgrade -y

# 3. Установка ZFS
apt install -y zfsutils-linux

# 4. Создание ZFS-пулов с зеркалированием
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi

# 5. Настройка сжатия для каждого пула
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4

# 6. Загрузка файла в каждый пул
for i in {1..4}; do
  wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log
done

# 7. Загрузка и распаковка архива с экспортированным пулом
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
tar -xzvf archive.tar.gz

# 8. Импорт пула otus из каталога zpoolexport
zpool import -d zpoolexport/
zpool import -d zpoolexport/ otus

# 9. Загрузка файла для восстановления снапшота
#В методичке нет кавычек от https до конца слова download, поэтому команда не отработает без исправления.
wget -O otus_task2.file --no-check-certificate 'https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download'

# 10. Восстановление снапшота в пул otus
zfs receive otus/test@today < otus_task2.file

# 11. Поиск и вывод секретного сообщения
secret_path=$(find /otus/test -name "secret_message" | head -1)
if [[ -n "$secret_path" ]]; then
  echo "Секретное сообщение найдено по пути: $secret_path"
  cat "$secret_path"
else
  echo "Секретное сообщение не найдено."
fi

