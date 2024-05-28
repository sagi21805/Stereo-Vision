#!/bin/sh
sudo apt update && sudo apt upgrade  -y 
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python

pip install requirements.txt -r 

curl -s https://get.modular.com | sh -

modular install mojo

