# mayan-edms terraform digitalocean setup

This is a simple example terraform project that sets up a digitalocean droplet and volume at digitalocean for the [mayan edms](https://www.mayan-edms.com/).

## What is setup?
A [simple docker installation for mayan edms](https://docs.mayan-edms.com/chapters/docker/install_simple.html) consisting of an application container, a postgresql container and a redis container. The mayan-edms only listens at 
8080 on localhost. A nginx reverse proxy is used for SSL termination and proxy passes than from port 443 to 8080.

## How to use it?
Adjust the terraform.tfvars:
* Generate a ssh-key pair without a passphrase and adjust the terraform_public_ssh_key and terraform_private_ssh_key accordingly.
* desktop_public_ssh_key is a key for you to log into the droplet.
* do_token has to be your DigitalOcean access token.
* domain is required for the domain entry, if you don't own a domain remove the corresponding part from the main.tf and adjust the nginx.conf.
Also, adjust the nginx.conf to remove tls if desired.
* If you wish to encrypt the digitalocean volume via LUKA use the encryptDisk.sh script for initial setup and the mountEncryptedDisk script for later use.
* The updateOS.sh shell script is just a convenience script to make updating the droplet OS easier.
* Now just run terraform init followed up by terraform apply / destroy as usual.

## What is created at digitalocean?
* One droplet with 4 cpu and 8gb ram droplet with an attached volume.
* A firewall to allow inbound http/https connections to the droplet, but limit ssh to your ip address as provided via the terraform variables. 
* A project called mayan-edms to manage the droplet.
* A domain with a A-level and AAAA-level dns entry as well as a CNAME alias.
* One ssh public key for terraform and one for the desktop user (possible to be identical).
