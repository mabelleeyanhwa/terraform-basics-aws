#!/bin/bash
sudo yum update -y
sudo yum -y install docker
sudo service docker start 
sudo usermod -aG docker ec2-user
sudo chmod 666 /var/run/docker.sock
docker version
docker run --name helloworld -d -p ${server_port}:80 nginx