resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags       = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name = "${var.app_name}-gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.public_subnets)
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags              = {
    Name = "${var.app_name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags              = {
    Name = "${var.app_name}-private-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name = "${var.app_name}-public-route-table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

