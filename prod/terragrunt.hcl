include {
  path = find_in_parent_folders()
}

terraform {
  source = "../modules/vpc-cluster"
}
inputs = {
  env = "prod"
  vpc_cidr = "20.0.0.0/16"
  public_subnets = {
    ap-southeast-1a = "10.1.0.0/27"
    ap-southeast-1b = "10.1.1.0/27"
  }
  private_subnets = {
    ap-southeast-1a = "10.1.2.0/27"
    ap-southeast-1b = "10.1.3.0/27"
  }
  web_server_count = "2"
  public_key_path  = "~/.ssh/id_rsa.pub"
}