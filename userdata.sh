#!/bin/bash

# Install Ansible and redirect both stdout and stderr to userdata.log
sudo yum install ansible python3.12-pip -y &> /opt/userdata.log

# Install the python libraries to fetch the SSM Parameters.
sudo pip3.12 install  botocore boto3 &>> /opt/userdata.log

# Run ansible-pull to pull the playbook and redirect both stdout and stderr to userdata.log
ansible-pull -i localhost, -U https://github.com/abhijeet4022/project-ansible-deployment.git main.yml -e env=${env} -e component=${component} &>> /opt/userdata.log
