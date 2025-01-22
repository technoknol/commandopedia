#!/bin/bash

chmod 400 private.pem

# download files from server in (/var/www/html/folder) directory to local machine /home/user/_projects/folder
scp -i private.pem -r ubuntu@18.xxx.xxx.xxx:/var/www/html/folder /home/user/_projects/folder
