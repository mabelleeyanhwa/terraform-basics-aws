resource "aws_vpc" "cluster" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  #instance_tenancy = "dedicated"
}

resource "aws_internet_gateway" "cluster_gateway" {
  vpc_id = aws_vpc.cluster.id
}

resource "aws_subnet" "public-subnet" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.cluster.id
  availability_zone = element(keys(var.public_subnets), count.index)
  cidr_block        = element(values(var.public_subnets), count.index)
  depends_on        = [aws_internet_gateway.cluster_gateway]
}

resource "aws_subnet" "private-subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.cluster.id
  availability_zone = element(keys(var.private_subnets), count.index)
  cidr_block        = element(values(var.private_subnets), count.index)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster_gateway.id
  }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.cluster.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
}

resource "aws_route_table_association" "public-subnet" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-subnet" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = {
    Name = "gw NAT"
  }
}
