data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_a = data.aws_availability_zones.available.names[0]
  az_b = data.aws_availability_zones.available.names[1]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = local.az_a
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = local.az_b
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = local.az_b

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = local.az_b

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl" "allow_all" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "allow-all-nacl"
  }
}

resource "aws_network_interface" "public2_eni" {
  subnet_id = aws_subnet.public2.id

  tags = {
    Name = "public2-eni"
  }
}
