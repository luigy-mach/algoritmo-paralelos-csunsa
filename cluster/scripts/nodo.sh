#!/bin/bash      
#variables
my_ip=192.168.0.0 #default
my_username=test20 #default
my_pass=test20 #default


#install
#sudo apt-get install expect -y
#sudo apt­-get install openssh-server -y

# paso 1 - obteniendo IP
my_ip="$(hostname -I | awk '{print $1}')"
echo "IP = $my_ip"

# paso 2 - creando usuario
sudo adduser $my_username --gecos "$my_username $my_username,$my_username,$my_username,$my_username" --disabled-password
echo "$my_username:$my_pass" | sudo chpasswd

# paso 3 - ingresando a my_username
./test.sh $my_username $my_pass 

# paso 4


# paso 5


# paso 6    
 