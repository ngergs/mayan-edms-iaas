# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

################
# template-files
################
resource "template_dir" "mayan-edms" {
  source_dir      = "${path.module}/files_templates"
  destination_dir = "${path.module}/files"

  vars = {
    domain = var.domain
  }
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
#resource "digitalocean_project" "mayan-edms" {
#  name        = var.project_name
#  description = "A project to experiment with the mayan-edms dms"
#  purpose = "Web Application" 
#  environment = "Development" 
#  resources = [digitalocean_droplet.mayan-edms.urn, digitalocean_domain.mayan-edms.urn, digitalocean_volume.mayan-edms.urn]
#}
data "digitalocean_project" "mayan-edms" {
  name        = var.project_name
}
resource "digitalocean_project_resources" "mayan-edms" {
  project = data.digitalocean_project.mayan-edms.id
  resources = [digitalocean_droplet.mayan-edms.urn, digitalocean_domain.mayan-edms.urn, data.digitalocean_volume.mayan-edms.urn]
}

################
# droplet
################
resource "digitalocean_droplet" "mayan-edms" {
  image  = "docker-18-04"
  name   = "mayan-edms"
  monitoring = true
  region = var.region
  size   = var.size
  ssh_keys = [data.digitalocean_ssh_key.desktop_public.id, digitalocean_ssh_key.terraform_public.id, data.digitalocean_ssh_key.laptop_public.id]
  volume_ids  = [data.digitalocean_volume.mayan-edms.id]
  provisioner "file" {
    source = "${template_dir.mayan-edms.destination_dir}/"
    destination = "/root/"
    connection {
        host = digitalocean_droplet.mayan-edms.ipv4_address
        user = "root"
        private_key = file(var.terraform_private_ssh_key)
        agent = false
    }
  }
   #Blocked by automatic updates
#  provisioner "remote-exec" {
#    script = "init.sh"
#    connection {
#        host = digitalocean_droplet.mayan-edms.ipv4_address
#        user = "root"
#        private_key = file(var.terraform_private_ssh_key)
#        agent = false
#    }
#  }
}
output "droplet_ip_addr" {
  value = digitalocean_droplet.mayan-edms.ipv4_address
  description = "ipv4 address of the created droplet"
}

################
# domain/dns
################
resource "digitalocean_domain" "mayan-edms" {
  name       = var.domain
  ip_address = digitalocean_droplet.mayan-edms.ipv4_address
}
resource "digitalocean_record" "mayan-edms-www" {
 domain = digitalocean_domain.mayan-edms.name
 type = "CNAME"
 name = "www"
 value = "@"
}

################
# initial volume
################
#resource "digitalocean_volume" "mayan-edms" {
#  region                  = var.region
#  name                    = "mayan-edms-volume"
#  size                    = 50
#  initial_filesystem_type = "ext4"
#}
data "digitalocean_volume" "mayan-edms" {
  name = "mayan-edms-volume"
}

################
# firewall
################
resource "digitalocean_firewall" "mayan_edms" {
  name = "http-all-ssh-ip-limited"

  droplet_ids = [digitalocean_droplet.mayan-edms.id]

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
