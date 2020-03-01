# -*- mode: ruby -*-
# vi: set ft=ruby :

vm_private_network_ip = ENV["VM_PRIVATE_NETWORK_IP"] || "192.168.7.25"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "private_network", ip: vm_private_network_ip
  config.vm.synced_folder ".", "/home/vagrant/mt-dev"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y make git zip \
      docker.io docker-compose \
      mysql-client \
      libio-socket-ssl-perl
    adduser vagrant docker
  SHELL

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
  end
end
