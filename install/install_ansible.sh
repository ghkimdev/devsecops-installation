#!/bin/bash

ssh-keygen -t rsa -b 3072 -f ~/.ssh/id_rsa -N ""

sudo apt update -qq
sudo apt install -y python3 python3-pip

pip3 install ansible boto3 botocore

cat <<EOF | sudo tee -a ~/.bashrc
export ANSIBLE_CONFIG=/opt/ansible/ansible.cfg
EOF
