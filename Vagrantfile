# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'fileutils'


Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202510.26.0"
  NUM_WORKERS = 2
  CTRL_CPU = 1
  NODE_CPU = 2
  CTRL_MEMORY = "4096"
  NODE_MEMORY = "6144"

  PROVIDER = "virtualbox"
 
  # define a controller  
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    # Step 2: Fixed IP for controller
    ctrl.vm.network "private_network", ip: "192.168.56.100"
    ctrl.vm.provider PROVIDER do |vb|
      vb.memory = CTRL_MEMORY
      vb.cpus = CTRL_CPU
    end

    ctrl.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "ansible/ctrl-full.yaml"
      ansible.groups = {
        "controller" => ["ctrl"]
      }
      ansible.extra_vars = { worker_count: NUM_WORKERS }
    end
  end

  (1..NUM_WORKERS).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      # Step 2: Fixed IPs starting at 101
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"

      node.vm.provider PROVIDER do |vb|
        vb.memory = NODE_MEMORY
        vb.cpus = NODE_CPU
      end
      if i == NUM_WORKERS
        # Step 3: Provision with Ansible
        node.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "ansible/workers-full.yaml"
          ansible.limit = "workers"
          ansible.groups = {
            "controller" => ["ctrl"],
            "workers" => (1..NUM_WORKERS).map { |k| "node-#{k}" }
          }
          ansible.extra_vars = { worker_count: NUM_WORKERS }
        end
      end
    end
  end

    config.trigger.after [:provision, :up] do |trigger|
    trigger.name = "Generate Inventory"
    trigger.ruby do |env, machine|
      dest = "inventory.cfg"

      inventory  = "[controller]\n"
      inventory += "ctrl ansible_host=192.168.56.100 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/ctrl/virtualbox/private_key\n\n"

      inventory += "[workers]\n"
      (1..NUM_WORKERS).each do |i|
        inventory += "node-#{i} ansible_host=192.168.56.#{100 + i} ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/node-#{i}/virtualbox/private_key\n"
      end

      File.write(dest, inventory)
      puts "  -> Wrote inventory to #{dest}"
    end
  end
end
