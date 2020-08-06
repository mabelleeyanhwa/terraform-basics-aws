resource "aws_security_group" "intra_node_communication" {
  name        = "intra-node-communication"
  description = "Default security group that allows all instances in the VPC to talk to each other over any port and protocol."
  vpc_id      = aws_vpc.cluster.id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
}

resource "aws_security_group" "private_instance" {
  name        = "private_instance"
  description = "Security group that allows public subnet ingress to private instances on HTTP and HTTPS."
  vpc_id      = aws_vpc.cluster.id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_ingress" {
  name        = "public_ingress"
  description = "Security group that allows public ingress to instances on HTTP and HTTPS."
  vpc_id      = aws_vpc.cluster.id

  //  HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTP Proxy
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTPS Proxy
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//  This security group allows public egress from the instances for HTTP and
//  HTTPS, which is needed for yum updates, git access etc etc.
resource "aws_security_group" "public_egress" {
  name        = "-"
  description = "Security group that allows egress to the internet for instances over HTTP and HTTPS."
  vpc_id      = aws_vpc.cluster.id

  //  HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
