#!/bin/bash
#docker
ufw delete allow 2375/tcp
ufw delete allow 2376/tcp
ufw default deny incoming
mkdir -p /mnt/data/app
mkdir -p /mnt/data/redis
mkdir -p /mnt/data/postgres
docker-compose -f /root/docker-compose.yml up -d

#nginx
apt-get -y install nginx
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
ufw allow 'Nginx Full'
rm /etc/nginx/sites-enabled/default
mv nginx.conf /etc/nginx/sites-available/${domain}
rm -r /etc/letsencrypt/
mkdir -p /mnt/data/letsencrypt
ln -s /mnt/data/letsencrypt/ /etc/
rm /etc/nginx/sites-available/default
ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/
systemctl enable nginx
systemctl stop nginx
systemctl start nginx
