terraform {
  backend "s3" {
    bucket = "project1-terraform-state-bucket"
    key    = "project1/terraform.tfstate"
    region = "us-east-1"
  }
}
