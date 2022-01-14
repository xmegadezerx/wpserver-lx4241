#!/bin/bash
sudo apt-get update -y
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update -y",
sudo apt install git -y",
git clone https://github.com/xmegadezerx/wpserver-lx4241.git /tmp/wp
sudo apt install ansible -y
ansible-playbook /tmp/wp/ansible/wordpress/playbook.yml