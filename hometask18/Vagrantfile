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

