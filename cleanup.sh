#!/bin/bash

# Stop puppet
sudo systemctl stop puppet
sudo systemctl disable puppet

#Flush IPtables
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
sudo iptables -X

#Update /etc/environment
sudo sh -c 'echo -e "\nSECRET_ARN=arn:aws:secretsmanager:ap-southeast-1:536697230138:secret:eks-db-stack/mongodb-credentials-CMq8DE" >> /etc/environment'
