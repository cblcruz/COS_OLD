#!/bin/bash
sudo - su
echo "the Leader IP is:" $1
echo "command:"
echo "http://$1:9000/init/install-worker.sh?group=default&token=secret_token&user=cribl&install_dir=/opt/cribl"
echo "#####################################"
#sudo apt update 
echo ""
echo "Starging BootStrap"
sleep 5
sudo curl "http://$1:9000/init/install-worker.sh?group=default&token=secret_token&user=cribl&install_dir=/opt/cribl" | bash -
#curl "http://$1:9000/init/install-worker.sh?group=default&token=secret_token&user=cribl&install_dir=/opt/cribl" | bash –
echo "Permissions"
echo ""
sudo chown -R cribl:cribl /opt/cribl
echo "Bootstrap"
echo ""
sudo /opt/cribl/bin/cribl boot-start enable -u cribl
sudo systemctl enable cribl
sudo systemctl start cribl