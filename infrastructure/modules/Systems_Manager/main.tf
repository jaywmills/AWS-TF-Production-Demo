# Amazon Linux 2 Security Updates
data "aws_ssm_document" "al2_security_updates" {
  name            = "AWS-AmazonLinux2DefaultPatchBaseline"
}

resource "aws_ssm_association" "al2_ssm" {
  name                = data.aws_ssm_document.al2_security_updates.name
  schedule_expression = "rate(30 minutes)"


  targets {
    key    = "InstanceIds"
    values = [var.internal_webserver]
  }
}

# Windows Server 2019 Security Updates
data "aws_ssm_document" "windows_security_updates" {
  name            = "AWS-InstallWindowsUpdates"
}

resource "aws_ssm_association" "win_ssm" {
  name                = data.aws_ssm_document.windows_security_updates.name
  schedule_expression = "rate(30 minutes)"

  targets {
    key    = "InstanceIds"
    values = [var.internal_admin_workstation]
  }
}

# AL2 IAM Profile for Systems Manager
resource "aws_iam_instance_profile" "al2_iam_profile" {
  name = "al2_profile"
  role = aws_iam_role.al2_ssm_role.name
}

resource "aws_iam_role" "al2_ssm_role" {
  name = "al2_ssm_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "al2_ssm_managed" {
role       = aws_iam_role.al2_ssm_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# WIN IAM Profile for Systems Manager
resource "aws_iam_instance_profile" "win_iam_profile" {
  name = "win_profile"
  role = aws_iam_role.win_ssm_role.name
}

resource "aws_iam_role" "win_ssm_role" {
  name = "win_ssm_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "win_ssm_managed" {
role       = aws_iam_role.win_ssm_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# VPC Endpoints for Systems Manager
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  auto_accept         = true
  security_group_ids  = [var.security_group]
  subnet_ids          = [var.subnet_ids[0]]
  private_dns_enabled = true

  tags = {
    Name = "ssm"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.security_group]
  subnet_ids          = [var.subnet_ids[0]]
  private_dns_enabled = true

  tags = {
    Name = "ec2messages-ssm"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.security_group]
  subnet_ids          = [var.subnet_ids[0]]
  private_dns_enabled = true

  tags = {
    Name = "ec2-ssm"
  }
}