# ---------- AWS EC2 Instances ----------
# Public Bastion
resource "aws_instance" "Public_Bastion" {
  ami                         = var.linux_ami
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet[0]
  security_groups             = [var.public_bastion]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.AL2_keypair.id

  tags = {
    Name = "Public_Bastion"
  }
}

# Public Windows Bastion
resource "aws_instance" "Windows_Bastion" {
  ami                         = var.windows_ami
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet[1]
  security_groups             = [var.windows_rdp]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name

  tags = {
    Name = "Windows_Bastion"
  }
}

# Private Windows Internal Admin Workstation
resource "aws_instance" "Windows_Admin_Workstation" {
  ami                         = var.windows_ami
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet[0]
  security_groups             = [var.windows_admin_workstation]
  associate_public_ip_address = false
  iam_instance_profile        = var.win_instance_profile
  key_name                    = aws_key_pair.key_pair.key_name

  tags = {
    Name = "Windows_Admin_Workstation"
  }
}

# Internal Apache Webserver
resource "aws_instance" "Internal_Apache_Webserver" {
  ami                         = var.linux_ami
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet[1]
  security_groups             = [var.internal_apache_webserver]
  associate_public_ip_address = false
  iam_instance_profile        = var.al2_instance_profile
  user_data                   = file("userdata.tpl")
  key_name                    = aws_key_pair.AL2_keypair.id

  tags = {
    Name = "Internal_Apache_Webserver"
  }
}

# Load Balancer Target Group Attachment
resource "aws_lb_target_group_attachment" "webserver_tg" {
  target_group_arn = var.webserver_tg
  target_id        = aws_instance.Internal_Apache_Webserver.id
  port             = 443
}

# Key Pair for SSH
resource "aws_key_pair" "AL2_keypair" {
  key_name   = "AL2Key"
  public_key = file("~/.ssh/tf_keypair.pub")
}

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "windows-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}