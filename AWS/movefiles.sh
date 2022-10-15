#!/usr/bin/bash
sudo su root <<EOF
sudo mv /tmp/authorized_keys /home/povadmin/.ssh/authorized_keys
sudo chown -R povadmin:povadmin /home/povadmin/.ssh/authorized_keys
EOF