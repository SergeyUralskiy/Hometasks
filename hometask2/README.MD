Задание: Обновление ядра

Подключаемся по ssh к созданной виртуальной машины. Для этого в каталоге с нашим Vagrantfile вводим команду vagrant ssh Перед работами проверим текущую версию ядра: [vagrant@kernel-update ~]$ uname -r Получаем ответ 4.18.0-240.1.1.el8_3.x86_64 Далее подключим репозиторий, откуда возьмём необходимую версию ядра: sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm И получим ошибки Failed to set locale, defaulting to C Failed to download metadata for repo 'AppStream'

Это происходит потому, что образ CentOs необходимо сначала обновить, для этого указать репозиторий:

cd /etc/yum.repos.d/ sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* yum update -y

Затем установить текстовый редактор

yum install nano

Создать и открыть в редакторе файл

nano /etc/profile.d/locale.sh

Записать и сохранить строки

export LANG=en_US.UTF-8 export LANGUAGE=en_US.UTF-8 export LC_COLLATE=C export LC_CTYPE=en_US.UTF-8

Загрузить настройки

source /etc/profile.d/locale.sh

После этого удалось продолжить

подключим репозиторий, откуда возьмём необходимую версию ядра: sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

Установим последнее ядро из репозитория elrepo-kernel: sudo yum --enablerepo elrepo-kernel install kernel-ml -y

Параметр --enablerepo elrepo-kernel указывает что пакет ядра будет запрошен из репозитория elrepo-kernel. Уже на этом этапе можно перезагрузить нашу виртуальную машину и выбрать новое ядро при загрузке ОС. Если требуется, можно назначить новое ядро по-умолчанию вручную:

    Обновить конфигурацию загрузчика: sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    Выбрать загрузку нового ядра по-умолчанию: sudo grub2-set-default 0

Далее перезагружаем нашу виртуальную машину с помощью команды sudo reboot

После перезагрузки снова проверяем версию ядра (версия должна стать новее): [vagrant@kernel-update ~]$ uname -r 5.18.3-1.el8.elrepo.x86_64 На этом обновление ядра закончено.

Хотя ошибка Failed to set locale, defaulting to C осталась, ядро обновилось.

[vagrant@kernel-update ~]$ uname -r 6.8.9-1.el8.elrepo.x86_64

Для ускорения работ в случае разворачивания нескольких виртуальных машин вышеуказанные команды внесены в Vagrantfile в секции provision.

Соответственно для разворачивания виртуальной машины и обновления ядра теперь достаточно двух команд: vagrant up vagrant provisoin
