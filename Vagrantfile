# -*- mode: ruby -*-
# vi: set ft=ruby :

# if vagrant complains: "* Shell provisioner `args` must be a string or array." - it's usually an ENV value that's not set

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.56.100"
  config.vm.provision :shell, :path => "init.sh"
  config.vm.synced_folder '.', '/provision', nfs: true, :mount_options => ['nolock', 'vers=3', 'tcp', 'fsc', 'rw', 'noatime']
  config.vm.synced_folder '/Users/graham/Dev/github/SuiteCRM', '/vagrant', nfs: true, :mount_options => ['nolock', 'vers=3', 'tcp', 'fsc', 'rw', 'noatime']
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024 * 2
    v.cpus = 2
  end
end
