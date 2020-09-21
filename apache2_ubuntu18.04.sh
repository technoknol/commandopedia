#!/bin/sh
sudo apt update
sudo apt install -y apache2
sudo systemctl status apache2
hostname -I
sudo a2enmod rewrite
sudo a2enmod proxy
sudo a2enmod prody_http
sudo a2enmod ssl
sudo a2enmod proxy_balancer
sudo a2enmod proxy_wstunnel
