# S3 bucket for Terraform remote state file
resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "project1-terraform-state-bucket"
  tags = {
    Name        = var.app_name
    Environment = var.app_environment
  }
}

resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


