#!/bin/sh
cd ~
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs
echo 'node -v'
node -v
echo 'npm -v'
npm -v
sudo apt install build-essential -y

