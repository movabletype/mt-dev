# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "private_network", ip: "192.168.7.25"
  config.vm.synced_folder ".", "/home/vagrant/mt-dev"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y make git zip \
      docker.io docker-compose \
      mysql-client
    adduser vagrant docker
  SHELL

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
  end
end
