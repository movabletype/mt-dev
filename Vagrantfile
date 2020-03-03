# -*- mode: ruby -*-
# vi: set ft=ruby :

class MtDevCommand < Vagrant.plugin(2, :command)
  def error(status)
    print "\e[31m"
    puts "Got error"
    print "\e[0m"
    return status
  end

  def execute
    argv = @argv.join(" ")

    if argv == ""
      puts "Usage: vagrant mt-dev <sub-command>"
      return 1
    end

    command = "cd /home/vagrant/mt-dev && make " + argv

    with_target_vms(nil, single_target: true) do |vm|
      if vm.state.id != :running
        env = vm.action(:up)
        if vm.state.id != :running
          return error(1)
        end
      end

      env = vm.action(:ssh_run, ssh_run_command: command, ssh_opts: { extra_args: %W(-q -t) })

      status = env[:ssh_run_exit_status] || 0

      return status if status == 0

      return error(1)
    end
  end
end

class MtDev < Vagrant.plugin("2")
  name "mt-dev"

  command "mt-dev" do
    MtDevCommand
  end
end

vm_private_network_ip = ENV["VM_PRIVATE_NETWORK_IP"] || "192.168.7.25"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "private_network", ip: vm_private_network_ip
  config.vm.synced_folder ".", "/home/vagrant/mt-dev"
  config.vm.hostname = "mt-dev"

  config.ssh.forward_agent = true

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y make git zip \
      docker.io docker-compose \
      mysql-client
    # required by HTTP::Tiny
    apt-get install -y libio-socket-ssl-perl
    adduser vagrant docker
  SHELL

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
  end
end
