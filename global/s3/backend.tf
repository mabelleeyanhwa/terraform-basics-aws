# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-1"
    bucket         = "terraform-basics-state"
    dynamodb_table = "terraform-basics-locks"
    encrypt        = true
  }
}
