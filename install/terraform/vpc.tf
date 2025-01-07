# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name = "main-vpc"
  }
}

# Subnet
resource "aws_subnet" "my-public-subnet-1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "main-public-subnet"
  }
}

resource "aws_subnet" "my-public-subnet-2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "main-public-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my-gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "main-gw"
  }
}

resource "aws_route_table" "my-rtb-public" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-gw.id
  }

  tags = {
    Name = "main-public-route-table"
  }
}

resource "aws_route_table_association" "my-rtba-public-1" {
  subnet_id      = aws_subnet.my-public-subnet-1.id
  route_table_id = aws_route_table.my-rtb-public.id
}

resource "aws_route_table_association" "my-rtba-public-2" {
  subnet_id      = aws_subnet.my-public-subnet-2.id
  route_table_id = aws_route_table.my-rtb-public.id
}

