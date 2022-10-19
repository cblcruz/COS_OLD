terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.26.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# resource "aws_vpc" "pov_vpc" {
#   cidr_block = "172.16.0.0/16"

#   tags = {
#     Name = "cribl_pov_vpc"
#   }
# }

# resource "aws_subnet" "cribl_subnet" {
#   vpc_id            = aws_vpc.pov_vpc.id
#   cidr_block        = "172.16.10.0/24"
#   availability_zone = "us-west-2"

#   tags = {
#     Name = "cribl_pov_subnet"
#   }
# }

resource "aws_default_vpc" "cribl_pov" {
  tags = {
    Name = "Cribl_POV_test"
  }
}

resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cribl_key" {
  key_name   = "cribl_key"
  public_key = tls_private_key.linux_key.public_key_openssh
}

# We want to save the private key to our machine
# We can then use this key to connect to our Linux VM

resource "local_file" "linuxkey" {
  filename        = "linuxkey.pem"
  file_permission = "400"
  content         = tls_private_key.linux_key.private_key_openssh
}

resource "local_file" "cribl_key" {
  filename        = "authorized_keys"
  file_permission = "600"
  content         = tls_private_key.linux_key.public_key_openssh

  depends_on = [local_file.linuxkey,
    aws_security_group.leader_sg,
  ]
}
resource "null_resource" "NSCFConstantString" {
  provisioner "local-exec" {
    command = "export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES"
   }
}