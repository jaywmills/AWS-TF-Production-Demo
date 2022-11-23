# ---------- VPC ----------
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_id
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# ---------- Public Subnets ----------
resource "aws_subnet" "public_subnets" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]

  tags = {
    Name = "public_subnet_${count.index}"
  }
}

# ---------- Private Subnets ----------
resource "aws_subnet" "private_subnets" {
  count             = var.private_sn_count
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private_subnet_${count.index}"
  }
}

# ---------- Internet Gateway ----------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "IGW"
  }
}

# ---------- Public Route Table for Public Subnets ----------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public_Route_Table"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# ---------- Private Route Table for Private Subnets ----------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "Private_Route_Table"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.private_subnets[0].id
  route_table_id = aws_route_table.private_rt.id
}

# ---------- Elastic IP and NAT Gateway ----------
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "NAT_GW"
  }
}

resource "aws_eip" "elastic_ip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}