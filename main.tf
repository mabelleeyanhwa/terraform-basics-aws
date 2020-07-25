provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-0d6c336fc1df6d884"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum -y install docker
sudo service docker start 
sudo usermod -aG docker ec2-user
sudo chmod 666 /var/run/docker.sock
docker version
docker run --name helloworld -d -p ${var.server_port}:80 nginx
EOF
  tags = {
    Name = "terraform-docker-example"
  }
}

variable "server_port" {
  description = "The port that the server will use for HTTP requests"
  type        = number
  default     = 80
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
