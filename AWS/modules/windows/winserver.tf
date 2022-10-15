# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami = data.aws_ami.windows-2019.id
  instance_type = var.windows_instance_type
  subnet_id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.aws-windows-sg.id]
  source_dest_check = false
  key_name = aws_key_pair.key_pair.key_name
  user_data = data.template_file.windows-userdata.rendered 
  associate_public_ip_address = var.windows_associate_public_ip_address
  
  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.windows_data_volume_size
    volume_type           = var.windows_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name        = "windows-server-vm"
  }
}