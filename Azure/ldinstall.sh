#!/bin/bash
sudo -su
sudo apt update 
sudo apt install -y \
git
sudo mkdir -p /opt
cd /opt
sudo adduser cribl --home "/home/cribl" --gecos "Cribl Service User" --disabled-password
curl -Lso - $(curl https://cdn.cribl.io/dl/latest-x64) | sudo tar zxvf -
sudo /opt/cribl/bin/cribl mode-master -u secret_token
sudo chown -R cribl:cribl /opt/cribl
sudo /opt/cribl/bin/cribl boot-start enable -u cribl -m systemd
sudo systemctl start cribl
sudo reboot
