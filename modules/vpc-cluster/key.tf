resource "aws_key_pair" "keypair" {
  key_name   = "${var.env} cluster"
  public_key = file(var.public_key_path)
}
