resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.project}-${terraform.workspace}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename = "${path.module}/../../keys/${var.project}-${terraform.workspace}.pem"
  content  = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "ec2" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = count.index == 0 ? var.public_subnet_id : var.private_subnet_id
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = var.assign_public_ip && count.index == 0
  key_name = aws_key_pair.generated.key_name

  tags = {
    Name = "${var.project}-${terraform.workspace}-instance-${count.index + 1}"
  }
}
