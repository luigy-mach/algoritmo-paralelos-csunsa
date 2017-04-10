#!/bin/bash      
#variables
my_ip=0.0.0.0 #default
my_username=mpitest #default
my_pass=$my_username #default


#install
sudo apt-get install expect -y
sudo apt­-get install openssh-server -y
sudo apt-get install nfs-kernel-server -y
sudo apt-get install nfs-common -y


# paso 1 - obteniendo IP
my_ip="$(hostname -I | awk '{print $1}')"
echo "IP = $my_ip"

# paso 2 - creando usuario y dando privilegios de sudo
sudo adduser $my_username --gecos "$my_username $my_username,$my_username,$my_username,$my_username" --disabled-password
echo "$my_username:$my_pass" | sudo chpasswd
sudo adduser $my_username sudo

# paso 3 - ingresando a my_username
./key-gen_server.sh $my_username $my_pass 

 