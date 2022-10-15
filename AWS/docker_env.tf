## Create the satellite VM
resource "aws_instance" "satellite" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.satellite_box_size
  security_groups = [aws_security_group.satellite.name]
  key_name        = "cribl_key"
  user_data       = file("povadmin.sh")

  root_block_device {
    volume_size = var.satellite_disk_size
  }

  tags = {
    Name = "CC_TF_Satallite"
  }

  provisioner "file" {
    source      = "authorized_keys"
    destination = "/tmp/authorized_keys"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.linux_key.private_key_openssh
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo mv /tmp/authorized_keys /home/povadmin/.ssh/authorized_keys",
      "sudo chmod +x /tmp/movefiles.sh",
      "sudo /tmp/movefiles.sh",
      "sudo chown -R povadmin:povadmin /home/povadmin",
      "sudo rm -f /tmp/movefiles.sh"
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.linux_key.private_key_openssh
  }
}

resource "null_resource" "Ansible_satellite" {
  connection {
    host        = aws_instance.satellite.public_ip
    user        = "povadmin"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  triggers = {
    aws_instance = join(",", aws_instance.satellite.*.id)
  }

  provisioner "local-exec" {

    command = "sleep 30;ansible-playbook -i '${aws_instance.satellite.public_ip},' --private-key linuxkey.pem ./ansible/deploysatellite.yaml"
  }
  depends_on = [local_file.cribl_key,
    aws_instance.satellite
  ]
}

resource "null_resource" "redis" {
  count = var.redis ? 1 : 0
  connection {
    host        = aws_instance.satellite.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  provisioner "local-exec" {

    command = "sleep 30;ansible-playbook -i '${aws_instance.satellite.public_ip},' --private-key linuxkey.pem ./ansible/deployredis.yaml"
  }
  depends_on = [null_resource.Ansible_satellite,
    aws_instance.satellite
  ]

}

resource "null_resource" "minio" {
  count = var.minio ? 1 : 0
  connection {
    host        = aws_instance.satellite.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  triggers = {
    aws_instance = aws_instance.satellite.id
  }
  provisioner "local-exec" {

    command = "sleep 40;ansible-playbook -i '${aws_instance.satellite.public_ip},' --private-key linuxkey.pem ./ansible/deployminio.yaml"
  }
  depends_on = [aws_instance.satellite,
    null_resource.Ansible_satellite

  ]

}

resource "null_resource" "Splunk" {
  count = var.splunk ? 1 : 0
  connection {
    host        = aws_instance.satellite.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  provisioner "local-exec" {

    command = "sleep 30;ansible-playbook -i '${aws_instance.satellite.public_ip},' --private-key linuxkey.pem ./ansible/deploysplunk.yaml"
  }
  depends_on = [null_resource.Ansible_satellite,
    aws_instance.satellite
  ]

}

resource "null_resource" "elk" {
  count = var.elk ? 1 : 0
  connection {
    host        = aws_instance.satellite.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  provisioner "local-exec" {

    command = "sleep 20;ansible-playbook -i '${aws_instance.satellite.public_ip},' --private-key linuxkey.pem ./ansible/deployelk.yaml"
  }
  depends_on = [null_resource.Ansible_satellite,
    aws_instance.satellite
  ]
}