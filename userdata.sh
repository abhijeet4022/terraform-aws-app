#!/bin/bash

# Install Ansible and redirect both stdout and stderr to userdata.log
sudo yum install ansible -y &>> /opt/userdata.log

# Run ansible-pull to pull the playbook and redirect both stdout and stderr to userdata.log
ansible-pull -i localhost, -U https://github.com/abhijeet4022/project-ansible-deployment.git main.yml -e component=${component} &>> /opt/userdata.log
