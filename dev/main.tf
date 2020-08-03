module "cluster" {
  source = "../modules/vpc-cluster"

  vpc_cidr = "10.0.0.0/16"
  public_subnets = {
    ap-southeast-1a = "10.0.0.0/24"
    ap-southeast-1b = "10.0.1.0/24"
  }
  private_subnets = {
    ap-southeast-1a = "10.0.2.0/24"
    ap-southeast-1b = "10.0.3.0/24"
  }
  web_server_count = "2"
  public_key_path  = "~/.ssh/id_rsa.pub"
}
