#!/bin/sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
source ~/.profile
nvm ls-remote
echo "Choose node version you want to install."
read version
nvm install $version
echo 'node version : '
node -v