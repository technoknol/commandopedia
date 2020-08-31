# commandopedia
All Linux, Git commands collection from Self Experience... 



### gitextract.sh
Extracting all Added, Modified and deleted files from commits and prepare for deployment. Use it with below command, 
first revision and then HEAD so it will take range from that revision to HEAD, and include all the files, It will overwrite same files. 

```sh
$ ./gitextract.sh 1b84..HEAD
```

### apache2_ubuntu18.04.sh
Install apache2 on fresh ubuntu 18.04.
```sh
$ sudo ./apache2_ubuntu18.04.sh
```

### certbot_apache2_ubuntu18.04.sh
Install certbot for apache2 on fresh ubuntu 18.04.
```sh
$ sudo ./certbot_apache2_ubuntu18.04.sh
```

### certbot_nginx_ubuntu18.04.sh
Install certbot for nginx on fresh ubuntu 18.04.
```sh
$ sudo ./certbot_nginx_ubuntu18.04.sh
```


   [gitextract.sh]: <https://github.com/technoknol/commandopedia/blob/master/gitextract.sh>
   
