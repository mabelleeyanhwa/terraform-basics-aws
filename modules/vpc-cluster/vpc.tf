resource "aws_vpc" "cluster" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  #instance_tenancy = "dedicated"
}

resource "aws_internet_gateway" "cluster_gateway" {
  vpc_id = "${aws_vpc.cluster.id}"
}

resource "aws_subnet" "public-subnet" {
  count             = "${length(var.public_subnets)}"
  vpc_id            = "${aws_vpc.cluster.id}"
  availability_zone = "${element(keys(var.public_subnets), count.index)}"
  cidr_block        = "${element(values(var.public_subnets), count.index)}"
  depends_on        = [aws_internet_gateway.cluster_gateway]
}

resource "aws_subnet" "private-subnet" {
  count             = "${length(var.private_subnets)}"
  vpc_id            = "${aws_vpc.cluster.id}"
  availability_zone = "${element(keys(var.private_subnets), count.index)}"
  cidr_block        = "${element(values(var.private_subnets), count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cluster_gateway.id}"
  }
}

resource "aws_route_table" "private" {
  count  = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.cluster.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat[count.index].id}"
  }
}

resource "aws_route_table_association" "public-subnet" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${aws_subnet.public-subnet[count.index].id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private-subnet" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${aws_subnet.private-subnet[count.index].id}"
  route_table_id = "${aws_route_table.private[count.index].id}"
}

resource "aws_instance" "nat" {
  count                       = "${length(var.public_subnets)}"
  ami                         = "ami-09a263088286e87d1" # this is a special ami preconfigured to do NAT
  availability_zone           = "${element(keys(var.public_subnets), count.index)}"
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.keypair.key_name
  vpc_security_group_ids      = [aws_security_group.nat[count.index].id]
  subnet_id                   = aws_subnet.public-subnet[count.index].id
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "VPC NAT"
  }
}

resource "aws_eip" "nat" {
  count    = "${length(var.public_subnets)}"
  instance = "${aws_instance.nat[count.index].id}"
  vpc      = true
}


