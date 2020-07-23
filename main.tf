provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0d6c336fc1df6d884"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-docker-example"
  }
}