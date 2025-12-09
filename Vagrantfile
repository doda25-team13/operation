# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202510.26.0"
  NUM_WORKERS = 2
  CTRL_CPU = 1
  NODE_CPU = 2
  CTRL_MEMORY = "4096"
  NODE_MEMORY = "6144"

  PROVIDER = "vmware_desktop"

  config.vm.provider PROVIDER do |v|
      v.linked_clone = true
  end
 
  # define a controller  
  config.vm.define "ctrl" do |ctrl|
    ctrl.vm.hostname = "ctrl"
    # Step 2: Fixed IP for controller
    ctrl.vm.network "private_network", ip: "192.168.56.100"
    ctrl.vm.provider PROVIDER do |vb|
#       vb.name = "ctrl"
      vb.memory = CTRL_MEMORY  # 4GB+
      vb.cpus = CTRL_CPU       # 1 core
    end

    # Step 3: Provision with Ansible
    # Run Full Playbook
    ctrl.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "ansible/ctrl-full.yaml"
      ansible.extra_vars = {
        kubeconfig_path: "/home/vagrant/.kube/config"
      }
      ansible.become = true
    end
  end


  (1..NUM_WORKERS).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.hostname = "node-#{i}"
      # Step 2: Fixed IPs starting at 101
      node.vm.network "private_network", ip: "192.168.56.#{100 + i}"

      node.vm.provider PROVIDER do |vb|
#         vb.name = "node-#{i}"
        vb.memory = NODE_MEMORY  # 6GB+
        vb.cpus = NODE_CPU       # 2 cores
      end

      # Step 3: Provision with Ansible
      # Run Full Playbook
      node.vm.provision "ansible" do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "ansible/node-full.yaml"
      end
    end
  end
end
