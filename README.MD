Первое, что нужно сделать, добавляем в начало файла ссылку на репозиторий box-ов.
ENV['VAGRANT_SERVER_URL'] = 'http://vagrant.elab.pro' и меняем название бокса на
актуальное из этого репозитория.

Домашняя работа по теме "SELinux - когда все запрещено"

Цель домашнего задания
Диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.

Описание домашнего задания
1. Запустить nginx на нестандартном порту 3-мя разными способами:
переключатели setsebool;
добавление нестандартного порта в имеющийся тип;
формирование и установка модуля SELinux.

Создаём каталог, в котором будут храниться настройки виртуальной машины. В каталоге создаём файл с именем Vagrantfile, 
добавляем в него следующее содержимое:

# -*- mode: ruby -*-
# vi: set ft=ruby :
ENV['VAGRANT_SERVER_URL'] = 'http://vagrant.elab.pro'
# подключаем репозиторий с боксами вагрант

MACHINES = {
  :selinux => {
        :box_name => "centos/8",
       
  },
}


Vagrant.configure("2") do |config|


  MACHINES.each do |boxname, boxconfig|


      config.vm.define boxname do |box|


        box.vm.box = boxconfig[:box_name]
        box.vm.box_version = boxconfig[:box_version]


        box.vm.host_name = "selinux"
        box.vm.network "forwarded_port", guest: 4881, host: 4881


        box.vm.provider :virtualbox do |vb|
              vb.customize ["modifyvm", :id, "--memory", "1024"]
              needsController = false
        end


        box.vm.provision "shell", inline: <<-SHELL
#добавляем репозиторий и обновляем систему
	cd /etc/yum.repos.d/
	sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
	sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
	yum update -y
#устанавливаем необходимые пакеты
	yum install -y setroubleshoot-server selinux-policy-mls setools-console policycoreutils-newrole
          #install epel-release
          yum install -y epel-release
          #install nginx
          yum install -y nginx
          #change nginx port
          sed -ie 's/:80/:4881/g' /etc/nginx/nginx.conf
          sed -i 's/listen       80;/listen       4881;/' /etc/nginx/nginx.conf
          #disable SELinux
          #setenforce 0
          #start nginx
          systemctl start nginx
          systemctl status nginx
          #check nginx port
          ss -tlpn | grep 4881
        SHELL
    end
  end
end
 


Результатом выполнения команды vagrant up станет созданная виртуальная машина с установленным nginx, который работает на порту 
TCP 4881. Порт TCP 4881 уже проброшен до хоста. SELinux включен.
Во время развёртывания стенда попытка запустить nginx завершится с ошибкой. Данная ошибка появляется из-за того, что SELinux 
блокирует работу nginx на нестандартном порту.
Заходим на сервер: vagrant ssh
Дальнейшие действия выполняются от пользователя root. Переходим в root пользователя: sudo -i

Для начала проверим, что в ОС отключен файервол: systemctl status firewalld
[root@selinux ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)
[root@selinux ~]#

Также можно проверить, что конфигурация nginx настроена без ошибок: nginx -t
[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@selinux ~]#

Далее проверим режим работы SELinux: getenforce 
[root@selinux ~]# getenforce
 Enforcing
[root@selinux ~]#


Должен отображаться режим Enforcing. Данный режим означает, что SELinux будет блокировать запрещенную активность.
Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool
Находим в логах (/var/log/audit/audit.log) информацию о блокировании порта
cat /var/log/audit/audit.log | grep denied
Копируем время, в которое был записан этот лог, и, с помощью утилиты audit2why смотрим 
grep 1720175939.214:1221 /var/log/audit/audit.log | audit2why

Утилита audit2why покажет почему трафик блокируется. Исходя из вывода утилиты, мы видим, что нам нужно поменять параметр nis_enabled. 
Включим параметр nis_enabled и перезапустим nginx: setsebool -P nis_enabled on
[root@selinux ~]# setsebool -P nis_enabled on
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-11-09 20:45:41 UTC; 6s ago

Проверить статус параметра можно с помощью команды: getsebool -a | grep nis_enabled
[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on

Проверить статус параметра можно с помощью команды: getsebool -a | grep nis_enabled
[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on
[root@selinux ~]#

Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим nis_enabled: setsebool -P nis_enabled off
После отключения nis_enabled служба nginx снова не запустится.

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:
Поиск имеющегося типа, для http трафика: semanage port -l | grep http
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000

[root@selinux ~]# semanage port -l | grep http
добавим порт в тип http_port_t: emanage port -a -t http_port_t -p tcp 4881

Перезапустим службу nginx и проверим её работу: systemctl restart nginx
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2021-11-07 02:52:59 UTC; 5s ago

Удалить нестандартный порт из имеющегося типа можно с помощью команды: semanage port -d -t http_port_t -p tcp 4881

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:

Попробуем снова запустить nginx: systemctl start nginx
Nginx не запуститься, так как SELinux продолжает его блокировать. Посмотрим логи SELinux, которые относятся к nginx: 
[root@selinux ~]# grep nginx /var/log/audit/audit.log

Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту: 
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp

Попробуем снова запустить nginx: systemctl start nginx
[root@selinux ~]# systemctl start nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-11-16 06:59:56 UTC; 16s ago

осле добавления модуля nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки. 

Просмотр всех установленных модулей: semodule -l
Для удаления модуля воспользуемся командой: semodule -r nginx
