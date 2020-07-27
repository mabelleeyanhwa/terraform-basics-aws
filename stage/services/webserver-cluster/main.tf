provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-0d6c336fc1df6d884"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = data.template_file.user_data.rendered
  tags = {
    Name = "terraform-docker-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-docker-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-basics-state"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-basics-locks"
    encrypt        = true
  }
}

data "template_file" "user_data" {
  template = file("user-data.sh")
  vars = {
    server_port = var.server_port
  }
}
