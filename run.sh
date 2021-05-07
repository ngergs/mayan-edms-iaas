#!/bin/bash
terraform -chdir=terraform init
terraform -chdir=terraform apply
ORIGINAL_PWD=$PWD
cd ansible
ansible-playbook -i ../inventory.ini playbook.yml
cd $ORIGINAL_PPWD
