terraform {
  backend "s3" {
    bucket = "terraform-state-aws-cloud-gaming-144842881551-us-east-1"
    key    = "terraform-state-aws-cloud-gaming.tfstate"
    region = "us-east-1"
  }
}