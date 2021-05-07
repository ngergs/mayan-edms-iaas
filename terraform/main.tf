# Configure the DigitalOcean Provider
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}

################
# output-ansible-inventory
################

locals {
  ansible_inventory = templatefile("${path.module}/templates/ansible_inventory.ini", {
    droplet_ipv4_address = digitalocean_droplet.mayan_edms.ipv4_address
    terraform_private_ssh_key=var.terraform_private_ssh_key
  })
}

resource "local_file" "ansible_inventory" {
  content = local.ansible_inventory
  filename = "../inventory.ini"
}

################
# ssh
################
resource "digitalocean_ssh_key" "terraform_public" {
    name = "terraform"
    public_key = file(var.terraform_public_ssh_key)
}
data "digitalocean_ssh_key" "desktop_public" {
    name = "desktop"
}
data "digitalocean_ssh_key" "laptop_public" {
    name = "laptop"
}

################
# project
################
data "digitalocean_project" "mayan_edms" {
  name        = var.project_name
}
resource "digitalocean_project_resources" "mayan_edms" {
  project = data.digitalocean_project.mayan_edms.id
  resources = [digitalocean_droplet.mayan_edms.urn, data.digitalocean_volume.mayan_edms.urn]
}

################
# droplet
################
resource "digitalocean_droplet" "mayan_edms" {
  image  = "docker-20-04"
  name   = "mayan-edms"
  ipv6 = true
  monitoring = true
  region = var.region
  size   = var.size
  ssh_keys = [data.digitalocean_ssh_key.desktop_public.id, digitalocean_ssh_key.terraform_public.id, data.digitalocean_ssh_key.laptop_public.id]
  volume_ids  = [data.digitalocean_volume.mayan_edms.id]
}
output "droplet_ipv4_addr" {
  value = digitalocean_droplet.mayan_edms.ipv4_address
  description = "ipv4 address of the created droplet"
}
output "droplet_ipv6_addr" {
  value = digitalocean_droplet.mayan_edms.ipv6_address
  description = "ipv6 address of the created droplet"
}

################
# initial volume
################
data "digitalocean_volume" "mayan_edms" {
  name = var.volume_name
}

################
# firewall
################
resource "digitalocean_firewall" "mayan_edms" {
  name = "http-all-ssh-ip-limited"

  droplet_ids = [digitalocean_droplet.mayan_edms.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.my_ip_address]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
