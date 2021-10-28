# -*- mode: ruby -*-
# vi: set ft=ruby :

class MtDevCommand < Vagrant.plugin(2, :command)
  def error(status)
    print "\e[31m"
    puts "Got error"
    print "\e[0m"
    return status
  end

  def with_captured_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  def execute
    require "shellwords"

    if @argv.empty?
      puts "Usage: vagrant mt-dev <sub-command>"
      return 1
    end

    commands = []

    if @argv[0] == "check-ssh-key"
      with_target_vms(nil, single_target: true) do |vm|
        if vm.state.id != :running
          env = vm.action(:up)
          if vm.state.id != :running
            return error(1)
          end
        end

        env = vm.action(:ssh_run, ssh_run_command: 'ssh git@github.com 2>&1 | grep "successfully authenticated" > /dev/null', ssh_opts: { extra_args: %W(-q -t) })

        status = env[:ssh_run_exit_status] || 0

        if status != 0
          puts <<MSG
Please execute this command first for copy your private key for github.

$ vagrant mt-dev copy-ssh-key ~/.ssh/id_rsa

~/.ssh/id_rsa is a typical filename for your private key, but it's may be different in your environment.

See also:
https://github.com/movabletype/mt-dev/wiki/Troubleshooting
MSG
          return 1
        end
      end

      print "\e[32m"
      puts "Succeeded!"
      print "\e[0m"

      return 0
    elsif @argv[0] == "copy-ssh-key"
      file = @argv.delete_at(1)
      key = begin
              File.read(file)
            rescue => e
              puts e
              return error(1)
            end

      commands += [
        "mkdir -p /home/vagrant/.ssh",
        "chmod 700 /home/vagrant/.ssh",
        "chown vagrant:vagrant /home/vagrant/.ssh",
        "echo -n #{Shellwords.shellescape(key)} > /home/vagrant/.ssh/id_rsa",
        "chmod 600 /home/vagrant/.ssh/id_rsa",
        "chown vagrant:vagrant /home/vagrant/.ssh/id_rsa",
        "ssh-keygen -l -f /home/vagrant/.ssh/id_rsa > /tmp/id_rsa_info",
        "perl -e '($len) = split(/ /, <>); if ($len <= 1024) { print qq{Invalid key length.\\n}; unlink(q{/home/vagrant/.ssh/id_rsa}); exit(1)}' < /tmp/id_rsa_info",
      ]
    elsif @argv[0] == "remove-ssh-key"
      commands += [
        "rm /home/vagrant/.ssh/id_rsa",
      ]
    elsif @argv[0] == "publish-ssh-config"
      config = with_captured_stdout do
        Vagrant.plugin("2").manager.commands["ssh-config".to_sym][0].call.new(%W(--host mt-dev), @env).execute
      end

      config_file = File.expand_path('.', '.ssh-config')
      fh = File.open(config_file, 'w')
      fh.puts config

      puts "You can connect to mt-dev by using this config file.\n"
      puts
      puts config_file

      return
    else
      argv = @argv.map { |str| Shellwords.shellescape(str) }.join(" ")
      commands.push("cd /home/vagrant/mt-dev && make " + argv)
    end

    with_target_vms(nil, single_target: true) do |vm|
      if vm.state.id != :running
        env = vm.action(:up)
        if vm.state.id != :running
          return error(1)
        end
      end

      env = vm.action(:ssh_run, ssh_run_command: commands.join(" && "), ssh_opts: { extra_args: %W(-q -t) })

      status = env[:ssh_run_exit_status] || 0

      if status == 0
        print "\e[32m"
        puts "Succeeded!"
        print "\e[0m"

        return status
      end

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

vm_private_network_ip = ENV["VM_PRIVATE_NETWORK_IP"] || "192.168.58.25"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "private_network", ip: vm_private_network_ip
  config.vm.hostname = "mt-dev"

  config.vm.synced_folder ".", "/vagrant", disabled: true
  if RUBY_PLATFORM =~ /darwin/
    config.vm.synced_folder ".", "/home/vagrant/mt-dev", type: "nfs", :mount_options => ["noatime", "vers=3", "udp", "nolock"]
  else
    config.vm.synced_folder ".", "/home/vagrant/mt-dev"
  end

  config.ssh.forward_agent = true

  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y make git zip \
      docker.io \
      mysql-client
    # required by HTTP::Tiny
    apt-get install -y libio-socket-ssl-perl
    curl -L https://github.com/docker/compose/releases/download/1.26.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    adduser vagrant docker
  SHELL

  config.vm.provider "virtualbox" do |vb|
    vb.memory = ENV["VM_VB_MEMORY"] || 2048
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
  end
end
