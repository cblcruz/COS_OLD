#!/usr/bin/bash
sudo su root <<EOF
adduser povadmin --home "/home/povadmin" --gecos "POV user" --disabled-password
usermod -aG sudo povadmin
echo 'povadmin   ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
mkdir -p /home/povadmin/.ssh
# touch /home/povadmin/.ssh/authorized_keys
chown -R povadmin:povadmin /home/povadmin/
chmod 700 /home/povadmin/.ssh
chmod 644 /home/povadmin/.ssh/authorized_keys
EOF