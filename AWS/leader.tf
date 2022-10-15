data "aws_ami" "ubuntu" {
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

## Create the VM
resource "aws_instance" "leader" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.leader_sg.name]
  key_name        = "cribl_key"
  user_data       = file("povadmin.sh")

  tags = {
    Name          = "CC_TF_LD"
    ansible-group = "leader"
    ansible-index = var.leader_count
  }

  provisioner "file" {
    source      = "authorized_keys"
    destination = "/tmp/authorized_keys"

    connection {
      host        = aws_instance.leader.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.linux_key.private_key_openssh
    }
  }
  depends_on = [
    local_file.cribl_key,
    aws_security_group.leader_sg,
  ]
}

resource "null_resource" "scripts" {

  provisioner "file" {
    source      = "movefiles.sh"
    destination = "/tmp/movefiles.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/movefiles.sh",
      "sudo /tmp/movefiles.sh",
      "sudo chown -R povadmin:povadmin /home/povadmin/.ssh/authorized_keys",
      "sudo rm -f /tmp/movefiles.sh",
    ]
  }

  connection {
    host        = aws_instance.leader.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.linux_key.private_key_openssh

  }
}

# # Define cribl vars for Ansible with Leader ip
resource "local_file" "cribl-vars" {
  content  = <<-DOC
  leader_ip: ${aws_instance.leader.public_ip}

  DOC
  filename = "./ansible/cribl_vars.yml"

}

# Deploy with Ansible

resource "null_resource" "Ansible_Laeder" {
  connection {
    host        = aws_instance.leader.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  triggers = {
    aws_instance_id = join(",", aws_instance.leader.*.id)
  }
  provisioner "local-exec" {

    command = "sleep 30;ansible-playbook -i '${aws_instance.leader.public_ip},' --private-key linuxkey.pem ./ansible/deployleader.yaml"
  }
  # provisioner "local-exec" {

  # #  command = "sleep 80;ansible-playbook -i '${aws_instance.leader.public_ip},' --private-key linuxkey.pem ./ansible/configleader.yaml"
  # }

  depends_on = [null_resource.scripts,
    aws_instance.leader,
    local_file.tf_ansible_vars_file_new,
    local_file.cribl_key,
    tls_private_key.linux_key
  ]
}