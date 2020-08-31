#!/bin/sh
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt install -y python-certbot-nginx

# Obtain Certificate command
# sudo certbot --apache -d your_domain -d www.your_domain
echo "Run following command to obtain a certificate."
echo "Replace your_domain with your domain."
echo "sudo certbot --apache -d your_domain -d www.your_domain"