# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  config.vm.synced_folder "./", "/usr/local/fieldpapers/", id: "vagrant-root",
    owner: "vagrant",
    group: "www-data",
    mount_options: ["dmode=775,fmode=664"]

  config.vm.provider :virtualbox do |vb, override|
    vb.memory = 1024
    vb.cpus = 1
    vb.name = "Field Papers Appliance"
    override.vm.box = "precise64"
    override.vm.box_url = "http://files.vagrantup.com/precise64.box"
    override.vm.network :private_network, ip: "192.168.33.10"
    override.vm.provision :ansible, :playbook => "provisioning/playbook.yml"
  end
end
