data "aws_ami" "ubuntu_worker" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "worker" {
  ami             = data.aws_ami.ubuntu_worker.id
  count           = var.workers_count
  instance_type   = var.worker_size
  security_groups = [aws_security_group.workers_sg.name]
  key_name        = "cribl_key"
  user_data       = file("povadmin.sh")

  tags = {
    Name          = "CC_TF_WK-${count.index + 1}"
    ansible-group = "workers"
    ansible-index = floor(count.index / var.workers_count)
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
      "sudo chown -R povadmin:povadmin /home/povadmin/.ssh/authorized_keys"
    ]
  }
  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  depends_on = [local_file.cribl_key,
    aws_instance.leader,
    aws_security_group.workers_sg
  ]
}
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      ansible_group_index   = aws_instance.worker.*.tags.ansible-index,
      ansible_group_workers = aws_instance.worker.*.tags.ansible-group,
      workers_ip            = aws_instance.worker.*.public_ip,
    }
  )
  filename = "inventory"
}
resource "null_resource" "Ansible4Ubuntu" {
  connection {
    #host        = self.public_ip
    host        = join(",", aws_instance.worker.*.public_ip)
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  triggers = {
    aws_instance = "${join(",", aws_instance.worker.*.id)}"
  }
  provisioner "local-exec" {

    command = "sleep 30;ansible-playbook -i inventory --private-key linuxkey.pem ./ansible/deploywrks.yaml"
  }
  depends_on = [local_file.cribl_key,
    aws_instance.leader,
    null_resource.Ansible_Laeder
  ]
}