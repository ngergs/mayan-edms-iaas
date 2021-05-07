# mayan-edms iaas digitalocean setup via terraform and ansible

This is a simple example project that sets up a digitalocean droplet and volume at digitalocean for the [mayan edms](https://www.mayan-edms.com/) via terraform and ansible.

## What is setup?
A [simple docker installation for mayan edms](https://docs.mayan-edms.com/chapters/docker/install_simple.html) consisting of an application container, a postgresql container and a redis container. The mayan-edms only listens at
8080 on localhost. A nginx reverse proxy is used for TLS termination and proxy passes than from port 443 to 8080. Fail2ban is setup to block an ip for 1 hour after 5 login requests within a minute from a single respective ip.
The volume that holds the data is encrypted via LUKS. Letsencrypt and certbot are used for the TLS certificate and certificate management.

## How to use it?
* Generate a secure-key for LUKS as well as DB passwords. Backup them in a safe place! The bash script generate_secure_key.sh generates them with the right structure and places them at the desired place ansible/roles/edms/files.
* All configs are symlinked in the vars directory.
  * Generate a ssh-key pair for ansible and terraform and adjust the terraform_public_ssh_key and terraform_private_ssh_key accordingly.
  * Generate a digitalocean project and volume for the data. Reference their names in the teraform and ansible configs.
  * Adjust all other configs, especially the do_token and the domain needs to be set. do_token has to be your DigitalOcean access token. If you don't own a domain remove the corresponding part from the nginx.conf in ansible/roles/edms/tempaltes.
* Now just run terraform in the terraform subfolder to create the server.
```
terraform init
terraform apply
```

Adjust the A and AAAA level DNS records for your domain followed up by running ansible in the ansible subfolder.
```
./run.sh playbook.yml 
```
Ansible will create a symlink from /etc/letsencrypt to /mnt/data/letsencrypt. If you do not already have a certificate the easist path is to set the ansible https variable to false. Then run certbot manually to get your certificate followed up settings the https ansible variable to true and rerunning ansible.

## What is created at digitalocean?
* One minimalistic droplet with 1 cpu and 2gb ram droplet.
* A firewall to allow inbound http/https connections to the droplet, but limit ssh to your ip address as provided via the terraform variables.
* One ssh public key for ansible and terraform.
